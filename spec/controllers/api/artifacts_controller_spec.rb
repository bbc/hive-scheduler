require 'spec_helper'

describe Api::ArtifactsController do

  describe "POST 'create'" do

    let(:job) { Fabricate(:job, state: :analyzing) }

    include_examples "job not found" do
      let(:http_verb) { :post }
      let(:action) { :create }
      let(:parameters) { { job_id: "fake" } }
    end

    context 'successfully upload artifact' do

      let(:file_name) { "android_build.apk" }
      let(:file_data) { fixture_file_upload('files/android_build.apk', 'application/vnd.android.package-archive') }

      it "creates a new artifact for the job" do
        expect { post :create, job_id: job.id, filename: file_name, data: file_data }.to change { job.reload.artifacts.count }.by(1)
      end

      describe "response" do

        before(:each) do
          post :create, job_id: job.id, filename: file_name, data: file_data
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
        post :create, job_id: job.id
      end

      it { should respond_with(:unprocessable_entity) }
      it "responds with the error messages in the json body" do
        expect(response_body).to eq({ "errors" => errors })
      end
    end
  end
end
