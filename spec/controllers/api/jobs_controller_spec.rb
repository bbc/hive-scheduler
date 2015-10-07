require 'spec_helper'

describe Api::JobsController do

  let(:response_body) { JSON.parse(response.body) }
  let(:response_state) { response_body['state'] }

  before(:each) do
    Job.any_instance.stub(:publish_to_queue).and_return(true)
  end

  shared_examples "rendering the job as a message" do

    it { should respond_with(:success) }

    it "coerced the job into a Hive::Messages::Job object" do
      expect(assigns(:job_message)).to be_instance_of(Hive::Messages::Job)
    end
    it "rendered using the JobRepresenter" do
      expect(assigns(:job_message).to_json).to eq response.body
    end
  end

  describe "GET #show" do

    before(:each) do
      get :show, id: job_id, format: :json
    end

    context "when job is found" do
      include_examples "rendering the job as a message"

      let(:job_id) { Fabricate(:job).id }
    end

    context "job does not exist" do
      let(:job_id) { -99 }

      it { should respond_with(:not_found) }
    end
  end

  describe "PATCH #reserve" do

    let(:job_reservation_command) { double(JobCommands::JobReservation, perform: job) }

    let(:queues) { ["queue_one", "queue_two"] }
    let(:reservation_details) { { "hive_id" => "99", "hive_pid" => "1024" } }

    before(:each) do
      Job.stub(:find)
      JobCommands::JobReservation.stub(new: job_reservation_command)

      patch :reserve, queue_names: queues.join(","), reservation_details: reservation_details, format: :json
    end

    context "job available for the specified queue names" do
      include_examples "rendering the job as a message"

      let!(:job) { Fabricate(:job) }

      it 'does not attempt to fetch a job by id (skips fetch_job before filter)' do
        expect(Job).to_not have_received(:find)
      end

      it "provided queue_names and reservation details to the job reservation command" do
        expect(JobCommands::JobReservation).to have_received(:new).with(queue_names: queues, reservation_details: reservation_details)
      end
      it { should respond_with(:success) }
    end

    context "no jobs available for specified queue names" do

      let!(:job) { nil }

      it 'does not attempt to fetch a job by id (skips fetch_job before filter)' do
        expect(Job).to_not have_received(:find)
      end
      it { should respond_with(:not_found) }
    end
  end

  describe 'PATCH #prepare' do

    let(:job) { Fabricate(:job, state: "reserved", reserved_at: Time.now) }
    let(:device_id) { 123 }

    include_examples "job not found" do
      let(:http_verb) { :put }
      let(:action) { :prepare }
      let(:parameters) { { job_id: "fake" } }
    end

    context 'successfully changed state' do
      include_examples "rendering the job as a message"

      before(:each) do
        job.stub(:reserve)
        Job.stub(find: job)
        Chamber.env.stub(hive_queues: hive_queues_setting)
        put :prepare, job_id: job.id, device_id: device_id
      end
      let(:hive_queues_setting) { false }

      it "found the job by id" do
        expect(Job).to have_received(:find).with(job.id.to_s)
      end
      it { should respond_with(:success) }
      it "returns the jobs state in the JSON response" do
        expect(response_body['state']).to eq "preparing"
      end

      it 'should have updated the device_id' do
        j = Job.find(job.id)
        j.device_id.should == device_id
      end
    end

    context 'failed to change state' do
      include_examples "job with errors" do
        let(:acting_method) { :start }
        let(:action) { :start }
        let(:params) { { job_id: job_id } }
      end
    end
  end

  describe "PATCH #update_results" do

    let!(:job) { Fabricate(:running_job) }

    include_examples "job not found" do
      let(:http_verb) { :patch }
      let(:action) { :update_results }
      let(:parameters) { { job_id: "fake" } }
    end

    context 'job results updated successfully' do


      let(:count) { 10 }
      let(:params) { { errored_count: count, running_count: count, passed_count: count, failed_count: count } }

      before(:each) { patch :update_results, params.merge(job_id: job.id) }

      include_examples "rendering the job as a message"
    end

    context 'failed to update' do

        let(:job_id) { 77 }
        let(:job)   { double(Job, valid?: false) }
        let(:params) { { job_id: job_id } }

        let(:errors) { ["something went wrong"] }

        let(:job_results_updater) { double(JobCommands::JobResultsUpdater, perform: job) }

        before(:each) do
          JobCommands::JobResultsUpdater.stub(new:job_results_updater)
          job.stub_chain(:errors, :full_messages).and_return(errors)
          patch :update_results, job_id: job_id
        end

        it { should respond_with(:unprocessable_entity) }
        it "responds with the jobs error messages in the json body" do
          expect(response_body).to eq({ "errors" => errors })
        end
    end
  end

  describe 'PUT #complete' do

    let(:job) { Fabricate(:job, state: :analyzing) }

    include_examples "job not found" do
      let(:http_verb) { :put }
      let(:action) { :complete }
      let(:parameters) { { job_id: "fake" } }
    end

    context 'successfully changed state' do

      context 'when tests are failing' do
        include_examples "rendering the job as a message"

        before do
          job.update!(queued_count:0, running_count: 0, failed_count: 1, exit_value: 1)
          put :complete, job_id: job.id
        end

        it { should respond_with(:success) }
        it "responds with the updated job state" do
          expect(response_state).to eq(job.reload.state.to_s)
        end
      end

      context 'when all tests are passing' do
        include_examples "rendering the job as a message"

        before(:each) do
          job.update!(queued_count: 0, running_count: 0, failed_count: 0, errored_count: 0, passed_count: 1, exit_value: 0)
          put :complete, job_id: job.id
        end

        it { should respond_with(:success) }
        it "responds with the updated job state of 'passed'" do
          expect(response_state).to eq("complete")
        end
      end

      context 'tests are in errored or running state' do
        include_examples "rendering the job as a message"

        before(:each) do
          job.update!(running_count: 1, errored_count: 1)
          put :complete, job_id: job.id
        end

        it { should respond_with(:success) }
        it "responds with the updated job state of 'errored'" do
          expect(response_state).to eq("complete")
        end
      end
    end

    context 'failure to change state' do
      include_examples "job with errors" do
        let(:acting_method) { :end }
        let(:action) { :end }
        let(:params) { { job_id: job_id } }
      end
    end
  end

  describe 'PUT #error' do

    let(:job) { Fabricate(:running_job) }

    include_examples "job not found" do
      let(:http_verb) { :put }
      let(:action) { :error }
      let(:parameters) { { job_id: "fake" } }
    end

    context 'successfully change state' do

      before(:each) do
        patch :error, job_id: job.id
      end

      include_examples "rendering the job as a message"
    end

    context 'failure to change state' do
      include_examples "job with errors" do
        let(:acting_method) { :error }
        let(:action) { :error }
        let(:params) { { job_id: job_id } }
      end
    end
  end

  describe 'PUT #report_artifacts' do

    let(:job) { Fabricate(:job, state: :complete) }

    include_examples "job not found" do
      let(:http_verb) { :put }
      let(:action) { :report_artifacts }
      let(:parameters) { { job_id: "fake" } }
    end

    context 'successfully upload artifact' do

      let(:file_name) { "android_build.apk" }
      let(:file_data) { fixture_file_upload('files/android_build.apk', 'application/vnd.android.package-archive') }

      it "creates a new artifact for the job" do
        expect { put :report_artifacts, job_id: job.id, filename: file_name, data: file_data }.to change { job.reload.artifacts.count }.by(1)
      end

      describe "response" do

        before(:each) do
          put :report_artifacts, job_id: job.id, filename: file_name, data: file_data
        end

        it { should respond_with(:success) }
        it "responds with new artifact_id" do
          expect(response_body['artifact_id']).to eq job.reload.artifacts.last.id
        end
      end
    end

    context "artifact could not be uploaded and has errors" do

      let(:errors) { ["something went wrong uploading artifact"] }

      before(:each) do
        Artifact.any_instance.stub(save: false)
        Artifact.any_instance.stub_chain(:errors, :full_messages).and_return(errors)
        put :report_artifacts, job_id: job.id
      end

      it { should respond_with(:unprocessable_entity) }
      it "responds with the error messages in the json body" do
        expect(response_body).to eq({ "errors" => errors })
      end
    end
  end
end
