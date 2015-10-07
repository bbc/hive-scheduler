require "spec_helper"

describe Builders::TestRail::BatchBuilder do
  include ActionDispatch::TestProcess

  describe "validations" do

    it { should validate_presence_of(:project_id) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:build) }
    it { should validate_presence_of(:version) }
  end

  describe "class methods" do

    describe ".build" do

      let(:batch_builder) { double(Builders::TestRail::BatchBuilder, perform: :batch) }

      before(:each) do
        Builders::TestRail::BatchBuilder.stub(new: batch_builder)
      end

      let!(:resulting_batch) { Builders::TestRail::BatchBuilder.build(:build_args) }

      it "instantiates a builder instance using the provided arguments" do
        expect(Builders::TestRail::BatchBuilder).to have_received(:new).with(:build_args)
      end

      it "delegates (calls) batch creation to BatchBuilders::TestRailBatchBuilder#perform" do
        expect(batch_builder).to have_received(:perform)
      end

      it "returns the value passed back from BatchBuilders::TestRailBatchBuilder#perform" do
        expect(resulting_batch).to eq :batch
      end
    end
  end

  describe "instance methods" do

    let(:batch_builder) { Builders::TestRail::BatchBuilder.new(builder_args) }

    let(:test_rail_namespace) { "test_instance" }
    let(:test_rail_user) { "test_instance@bbc.co.uk" }
    let(:test_rail_password) { "test_instance" }

    let(:test_rail_settings) { { test_rail_namespace => { "user" => test_rail_user, "password" => test_rail_password } } }

    describe "#perform" do

      before(:each) do
        Chamber.env.stub(test_rail: test_rail_settings)
      end

      let(:test_rail_plan) { Fabricate(:test_rail_plan_with_tests) }
      let(:project) { Fabricate(:project, builder_name: "test_rail", builder_options: project_builder_options) }

      let(:project_builder_options) do
        { "test_rail_plan_id" => test_rail_plan.id, "test_rail_instance" => "test_instance" }
      end

      let(:name) { "Batch #{Fabricate.sequence(:batch_number)}" }
      let(:build) { fixture_file_upload("files/android_build.apk", "application/vnd.android.package-archive") }
      let(:version) { Fabricate.sequence(:version_number) }
      let(:tests_per_job) { 8 }

      let(:builder_args) do
        {
            project_id:          project.id,
            name:                name,
            build:               build,
            version:             version,
            execution_variables: { "tests_per_job" => tests_per_job }
        }
      end

      it "returns a batch" do
        expect(batch_builder.perform).to be_instance_of(Batch)
      end

      describe "connecting to the correct test rail instance" do

        before(:each) do
          batch_builder.perform
        end

        subject { TestRail.configuration }

        its(:user) { should eq test_rail_user }
        its(:password) { should eq test_rail_password }
        its(:namespace) { should eq test_rail_namespace }
      end

      describe "the returned batch" do

        let(:batch) { batch_builder.perform }
        subject { batch }

        it { should be_valid }
        it "can be persisted" do
          expect(batch.save).to be_true
        end

        its(:project_id) { should eq project.id }
        its(:name) { should eq name }
        its(:version) { should eq version }
        its(:tests_per_job) { should eq tests_per_job }

        describe "the batches job groups" do

          let(:test_rail_job_group_builder) { double(Builders::TestRail::JobGroupBuilder, perform: JobGroup.new) }

          before(:each) do
            Builders::TestRail::JobGroupBuilder.stub(new: test_rail_job_group_builder)
            batch
          end

          let(:job_groups) { batch.job_groups }
          let(:test_rail_runs) { test_rail_plan.runs }

          it "has a job group for every test rail plan" do
            expect(job_groups.size).to eq test_rail_plan.runs.size
          end

          it "instantiated instances of TestRailJobGroupBuilder correctly" do
            test_rail_runs.each do |test_rail_run|
              expect(Builders::TestRail::JobGroupBuilder).to have_received(:new).with(batch: batch, test_rail_run: test_rail_run)
            end
          end

          it "created the correct number of job groups using the TestRailJobGroupBuilder" do
            expect(test_rail_job_group_builder).to have_received(:perform).exactly(test_rail_runs.size).times
          end
        end
      end
    end
  end
end
