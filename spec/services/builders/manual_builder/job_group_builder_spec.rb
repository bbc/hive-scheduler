require "spec_helper"

describe Builders::ManualBuilder::JobGroupBuilder do

  describe "validations" do

    let(:builder_args) { nil }

    it { should validate_presence_of(:batch) }
    it { should validate_presence_of(:queue) }
  end

  describe "class methods" do

    describe ".build" do

      let(:job_group_builder) { double(Builders::ManualBuilder::JobGroupBuilder, perform: :job_group) }

      before(:each) do
        Builders::ManualBuilder::JobGroupBuilder.stub(new: job_group_builder)
      end

      let!(:resulting_job_group) { Builders::ManualBuilder::JobGroupBuilder.build(:build_args) }

      it "instantiates a builder instance using the provided arguments" do
        expect(Builders::ManualBuilder::JobGroupBuilder).to have_received(:new).with(:build_args)
      end

      it "delegates (calls) job_group creation to JobGroupBuilders::ManualCucumberTagsJobGroupBuilder#peform" do
        expect(job_group_builder).to have_received(:perform)
      end

      it "returns the value passed back from JobGroupBuilders::ManualCucumberTagsJobGroupBuilder#peform" do
        expect(resulting_job_group).to eq :job_group
      end
    end
  end

  describe "instance methods" do
    let(:job_group_builder) { Builders::ManualBuilder::JobGroupBuilder.new(builder_args) }


    describe "#perform" do

      let(:cucumber_tags) { "@new_tests,@other_tests" }

      let(:project) do
        Fabricate(:project, builder_name: "manual_builder")
      end
      let(:batch) { Fabricate(:batch, execution_variables: { "tests" => [], "tests_per_job" => "2", "cucumber_tags" => cucumber_tags }, project: project) }
      let(:queue) { "queue_one" }


      let(:builder_args) do
        {
            batch: batch,
            queue: queue
        }
      end

      it "returns a job group" do
        expect(job_group_builder.perform).to be_instance_of(JobGroup)
      end

      describe "the returned job group" do

        let(:job_group) { job_group_builder.perform }
        subject { job_group }

        it { should be_valid }

        it "can be persisted" do
          expect(job_group.save).to be_true
        end

        its(:batch_id) { should eq batch.id }
        its(:batch) { should eq batch }
        its(:queue_name) { should eq queue }
        its(:name) { should eq "#{project.name} (#{queue})" }

        describe "the job groups execution variables" do

          it "does not populate any execution variables" do
            expect(job_group.execution_variables).to be_blank
          end
        end

        describe "the jobs in the job group" do

          let(:jobs) { job_group.jobs }
          let(:single_job) { jobs.first }

          it "created a single job for the entire job group" do
            expect(jobs.size).to eq 1
          end

          it "named the job correctly using the project name and queue name" do
            expect(single_job.job_name).to eq "#{project.name} (#{queue})"
          end

          it "set the queued count for the single job to nil as it is unknown" do
            expect(single_job.queued_count).to be_nil
          end
        end
      end
    end
  end
end
