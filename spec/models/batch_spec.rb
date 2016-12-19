require 'spec_helper'

describe Batch do

  it { should be_a(Batch::BatchValidations) }
  it { should be_a(Batch::BatchChart) }
  it { should be_a(Batch::BatchAssociations) }
  it { should be_a(Batch::BatchScopes) }

  it { should serialize(:target_information).as(::ActiveRecord::Coders::JSON) }
  it { should serialize(:execution_variables).as(::ActiveRecord::Coders::JSON) }

  before do
    Job.any_instance.stub(:publish_to_queue).and_return(true)
  end

  describe "delegates" do
    it { should delegate_method(:requires_build?).to(:project) }
    it { should delegate_method(:execution_variables_required).to(:project) }
  end

  describe "default values" do

    let(:batch) { Batch.new }

    describe "#number_of_automatic_retries" do

      it "defaults to 1" do
        expect(batch.number_of_automatic_retries).to eq 1
      end
    end
  end

  describe "callbacks" do

    describe "after_initialize" do

      describe "copy_execution_variables" do

        context "batch is a new record" do

          let(:batch) { Batch.new(project_id: project_id) }

          context "batch does not have a project" do

            let(:project_id) { nil }

            it "does not assign any execution_variables" do
              expect(batch.execution_variables).to be_blank
            end
          end

          context "batch has a project assigned" do

            let(:project_id) { project.id }
            let(:project) { Fabricate(:project, execution_variables: project_execution_variables) }

            let(:project_execution_variables) { { "foo" => "project_foo", "bar" => "project_bar", "other_thing" => "project_thing" } }

            context "no execution_variables have been provided to initialize with" do

              it "copies the execution_variables from the project" do
                expect(batch.execution_variables).to eq(project.execution_variables)
              end
            end

            context "execution_variables have been provided to initialize with" do

              let(:batch) { Batch.new(project_id: project_id, execution_variables: batch_execution_variables) }
              let(:batch_execution_variables) { { "foo" => "batch_foo", "bar" => "batch_bar", "other_thing" => "" } }

              let(:expected_execution_variables) do

                expected_execution_variables = { "foo" => "batch_foo", "bar" => "batch_bar", "other_thing" => "project_thing" }

                project.builder.execution_variables_required.each do |field|
                  expected_execution_variables[field.name.to_s]=field.default_value
                end

                project.script.execution_variables.each do |field|
                  expected_execution_variables[field.name.to_s]=field.default_value
                end

                expected_execution_variables
              end

              it "overrides any project execution variables with the ones provided except where they are blank" do
                expect(batch.execution_variables).to eq(expected_execution_variables)
              end
            end
          end
        end

        context "batch is an existing record" do

          let(:batch) { Fabricate(:batch, execution_variables: { "foo" => "bar" }) }

          it "does not amend execution_variables on load" do

            expect { batch.reload }.to_not change { batch.execution_variables }
          end
        end
      end
    end
  end

  describe "instance methods" do

    describe "#state" do

      let(:batch) { Fabricate(:batch) }

      subject { batch.state }

      context "batch does not have any jobs" do

        before(:each) do
          expect(batch.jobs).to be_empty
        end

        it { should eq :invalid }
      end

      context "batch has jobs" do

        let!(:job_group) { Fabricate(:job_group, batch: batch, jobs: jobs) }
        let!(:jobs_belonging_to_different_batches) { Fabricate.times(10, :job) }

        before(:each) do
          expect(batch.jobs).to_not be_empty
        end

        context "all jobs are in the same state" do

          let(:jobs) { 3.times.collect { Fabricate.build(:job, state: jobs_state) } }

          context "all jobs are queued" do

            let(:jobs_state) { :queued }

            it { should eq :queued }
          end

          context "all jobs are running" do

            let(:jobs_state) { :running }

            it { should eq :running }
          end

          context "all jobs have completed" do

            let(:jobs_state) { :complete }

            it { should eq :complete }
          end

        end

        context "jobs are in different states" do

          context "some jobs are queued, some jobs are running" do

            let(:jobs) do
              [
                  Fabricate.build(:job, state: :queued),
                  Fabricate.build(:job, state: :reserved),
                  Fabricate.build(:job, state: :running)
              ]
            end

            it { should eq :running }
          end

          context "some jobs have completed, some jobs have errored" do

            let(:jobs) do
              [
                  Fabricate.build(:job, state: :errored),
                  Fabricate.build(:job, state: :reserved),
                  Fabricate.build(:job, state: :complete)
              ]
            end

            it { should eq :errored }
          end

          context "some jobs are running, some jobs have errored" do

            let(:jobs) do
              [
                  Fabricate.build(:job, state: :running),
                  Fabricate.build(:job, state: :reserved),
                  Fabricate.build(:job, state: :errored)
              ]
            end

            it { should eq :running }
          end

          context "jobs have retries so the originals should be discounted" do

            let(:original_job_one) { Fabricate.build(:job, state: :complete, result: :failed) }
            let!(:job_one_retry) { Fabricate.build(:job, original_job: original_job_one, state: :complete, result: :passed) }

            let(:original_job_two) { Fabricate.build(:job, state: :errored) }
            let!(:job_two_first_retry) { Fabricate.build(:job, original_job: original_job_two, state: :complete, result: :failed) }
            let!(:job_two_second_retry) { Fabricate.build(:job, original_job: job_two_first_retry, state: :complete, result: :passed) }

            let!(:job_three) { Fabricate.build(:job, state: :complete, result: :passed) }

            let(:jobs) do
              [
                  original_job_one,
                  job_one_retry,
                  original_job_two,
                  job_two_first_retry,
                  job_two_second_retry,
                  job_three
              ]
            end

            it { should eq :passed }
          end
        end
      end
    end

    describe "#requires_build?" do

      let(:batch) { Batch.new(project: project) }

      subject { batch.requires_build? }

      context "project is nil" do

        let(:project) { nil }

        it { should eq nil }
      end

      context "project is not nil" do

        let(:project) { Project.new.tap { |p| p.stub(requires_build?: script_value) } }
        let(:script_value) { true }

        it { should eq script_value }
      end
    end

    context 'meta scope methods' do

      let(:batch) { Fabricate(:batch) }
      let(:job_group) { Fabricate(:job_group, batch: batch) }

      context "job states" do

        context "jobs have not been retried" do

          before do
            %w{ queued running errored }.each_with_index do |state, index|
              (index + 1).times { Fabricate(:job, batch: batch, state: state, job_group: job_group) }
            end
            %w{ passed failed }.each_with_index do |state, index|
              (index + 4).times { Fabricate(:job, batch: batch, state: 'complete', result: state, job_group: job_group) }
            end
          end

          %w{ queued running errored passed failed }.each_with_index do |state, index|

            context "#jobs_#{state}" do

              let(:expected_total) { index + 1 }

              it "should provide count of #{state} jobs" do
                batch.send("jobs_#{state}").should == expected_total
              end
            end
          end
        end

        context "jobs have been retried" do
          let!(:failed_job_one) { Fabricate(:failed_job, batch: batch) }
          let!(:failed_job_two) { Fabricate(:failed_job, batch: batch) }

          let!(:errored_job_one) { Fabricate(:errored_job, batch: batch) }
          let!(:errored_job_two) { Fabricate(:errored_job, batch: batch) }

          let!(:retry_of_failed_job_one) { Fabricate(:job, batch: batch, original_job: failed_job_one) }
          let!(:retry_of_errored_job_two) { Fabricate(:job, batch: batch, original_job: errored_job_two) }

          it "discounts retried failed jobs" do
            expect(batch.jobs_failed).to eq 1
          end

          it "discounts retried errored jobs" do
            expect(batch.jobs_errored).to eq 1
          end

          it "counts the newly retried jobs" do
            expect(batch.jobs_queued).to eq 2
          end
        end
      end

      context 'total job count methods' do

        before do
          2.times { Fabricate(:job, batch: batch, job_group: job_group, queued_count: 50, running_count: 20, passed_count: 10, failed_count: 5, errored_count: 2) }
          # Fabricate(:job, batch: batch, job_group: job_group, state: 'retried', queued_count: 99, running_count: 99, passed_count: 99, failed_count: 99, errored_count: 99)
        end

        %w{ queued running passed failed errored }.each do |m|

          context "#total_#{m}" do

            let(:expected_total) { Job.active.to_a.sum(&"#{m}_count".to_sym) }

            it "should provide sum of #{m} jobs, ignoring retried jobs" do
              batch.send("tests_#{m}").should == expected_total
            end

          end

        end

      end

    end

  end

  describe '#assets' do
    context 'single batch with single asset' do
      let(:target) { Target.create! requires_build: true }
      let(:script) { Script.create! target: target, name: 'Test script', template: 'Test template' }
      let(:project) { Project.create! script: script, name: 'Test project', builder_name: Builders::ManualBuilder.builder_name, repository: '' }
      let(:build) { [ Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/android_build.apk'), 'application/vnd.android.package-archive', false) ] }
      let(:batch) { BatchCommands::BuildBatchCommand.build(
          project_id: project.id,
          version: 1,
          build: build,
          name: 'Test batch'
        )
      }

      it 'returns a single asset for a single batch' do
        expect(batch.assets).to match_array([Asset.last])
      end
    end

    context 'two batches of the same project with different assets' do
      let(:target) { Target.create! requires_build: true }
      let(:script) { Script.create! target: target, name: 'Test script', template: 'Test template' }
      let(:project) { Project.create! script: script, name: 'Test project', builder_name: Builders::ManualBuilder.builder_name, repository: '' }
      let(:build1) { [ Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/android_build.apk'), 'application/vnd.android.package-archive', false) ] }
      let(:build2) { [ Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/android_build_2.apk'), 'application/vnd.android.package-archive', false) ] }
      let(:batch1) { BatchCommands::BuildBatchCommand.build(
          project_id: project.id,
          version: 1,
          build: build1,
          name: 'Batch one'
        )
      }
      let(:batch2) { BatchCommands::BuildBatchCommand.build(
          project_id: project.id,
          version: 1,
          build: build2,
          name: 'Batch two'
        )
      }

      it 'returns a single asset for each batch' do
        expect(batch1.assets.length).to eq 1
        expect(batch2.assets.length).to eq 1
      end

      it 'returns the correct asset for each batch' do
        expect(batch1.assets.first.file).to eq 'android_build.apk'
        expect(batch2.assets.first.file).to eq 'android_build_2.apk'
      end
    end
  end
end
