require "spec_helper"

describe Builders::ManualBuilder::BatchBuilder, type: :model  do
  include ActionDispatch::TestProcess

  describe "validations" do

    it { should validate_presence_of(:project_id) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:build) }
    it { should validate_presence_of(:version) }
  end

  describe "class methods" do

    describe ".build" do

      let(:batch_builder) { double(Builders::ManualBuilder::BatchBuilder, perform: :batch) }

      before(:each) do
        Builders::ManualBuilder::BatchBuilder.stub(new: batch_builder)
      end

      let!(:resulting_batch) { Builders::ManualBuilder::BatchBuilder.build(:build_args) }

      it "instantiates a builder instance using the provided arguments" do
        expect(Builders::ManualBuilder::BatchBuilder).to have_received(:new).with(:build_args)
      end

      it "delegates (calls) batch creation to BatchBuilders::ManualCucumberTagsBatchBuilder#peform" do
        expect(batch_builder).to have_received(:perform)
      end

      it "returns the value passed back from BatchBuilders::ManualCucumberTagsBatchBuilder#peform" do
        expect(resulting_batch).to eq :batch
      end
    end
  end

  describe "instance methods" do

    let(:batch_builder) { Builders::ManualBuilder::BatchBuilder.new(builder_args) }

    describe "#perform" do

      let(:cucumber_tags) { "@new_tests,@other_tests" }

      let(:queue_one) { "queue_one" }
      let(:queue_two) { "queue_two" }

      let(:queues) { [queue_one, queue_two] }
      let(:project) { Fabricate(:project, builder_name: "manual_builder", execution_variables: { "cucumber_tags" => cucumber_tags, "queues" => queues, "tests_per_job" => tests_per_job }) }


      let(:name) { "#{Fabricate.sequence(:batch_number)}" }
      let(:build) { fixture_file_upload("files/android_build.apk", "application/vnd.android.package-archive") }
      let(:version) { Fabricate.sequence(:version_number) }
      let(:tests_per_job) { 8 }

      let(:builder_args) do
        {
            project_id:    project.id,
            name:          name,
            build:         build,
            version:       version,
            tests_per_job: tests_per_job
        }
      end


      it "returns a batch" do
        expect(batch_builder.perform).to be_instance_of(Batch)
      end

      describe "the returned batch" do

        let(:batch) { batch_builder.perform }
        subject { batch }

        it { should be_valid }
        it "can be persisted" do
          expect(batch.save).to be_true
        end

        its(:project_id)      { should eq project.id }
        its(:name)            { should eq name }
        its(:version)         { should eq version }
        its(:tests_per_job)   { should eq tests_per_job }

        describe "the batches job groups" do

          before(:each) do
            Builders::ManualBuilder::JobGroupBuilder.stub(build: JobGroup.new)
            batch
          end

          let(:job_groups) { batch.job_groups }

          it "creates a job group for each queue in the batch" do
            expect(job_groups.size).to eq [queue_one, queue_two].size
          end

          it "used the ManualCucumberTags::JobGroupBuilder correctly" do
            [queue_one, queue_two].each do |queue|
              expect(Builders::ManualBuilder::JobGroupBuilder).to have_received(:build).with(batch: batch, queue: queue)
            end
          end
        end
      end
    end
  end
end

