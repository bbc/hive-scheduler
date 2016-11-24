require "spec_helper"
require "shoulda/matchers"

describe Builders::TestRail::JobGroupBuilder, type: :model  do

  describe "validations" do

    let(:builder_args) { nil }

    it { should validate_presence_of(:batch) }
    it { should validate_presence_of(:test_rail_run) }
  end

  describe "class methods" do

    describe ".build" do

      let(:job_group_builder) { double(Builders::TestRail::JobGroupBuilder, perform: :job_group) }

      before(:each) do
        Builders::TestRail::JobGroupBuilder.stub(new: job_group_builder)
      end

      let!(:resulting_job_group) { Builders::TestRail::JobGroupBuilder.build(:build_args) }

      it "instantiates a builder instance using the provided arguments" do
        expect(Builders::TestRail::JobGroupBuilder).to have_received(:new).with(:build_args)
      end

      it "delegates (calls) job_group creation to JobGroupBuilders::TestRailJobGroupBuilder#peform" do
        expect(job_group_builder).to have_received(:perform)
      end

      it "returns the value passed back from JobGroupBuilders::TestRailJobGroupBuilder#peform" do
        expect(resulting_job_group).to eq :job_group
      end
    end
  end

  describe "instance methods" do
    let(:job_group_builder) { Builders::TestRail::JobGroupBuilder.new(builder_args) }


    describe "#perform" do

      let(:batch) { Fabricate(:batch, execution_variables: {"tests_per_job" => "2"} ) }
      let(:test_rail_run) { Fabricate(:test_rail_run) }


      let(:test_rail_tests) { Fabricate.times(10, :test_rail_test) }


      let(:builder_args) do
        {
            batch:         batch,
            test_rail_run: test_rail_run
        }
      end

      before(:each) do
        test_rail_run.stub(tests: test_rail_tests)
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
        its(:queue_name) { should eq test_rail_run.config }
        its(:name) { should eq test_rail_run.name }

        describe "the job groups execution_variables" do

          it "stores the test rail run id" do
            expect(job_group.execution_variables[:run_id]).to eq test_rail_run.id
          end
        end

        describe "the jobs in the job group" do

          let(:jobs) { job_group.jobs }

          it "has correctly sliced the test rail run's tests using the tests_per_job attribute of the batch" do
            expect(jobs.size).to eq test_rail_tests.size/batch.tests_per_job
          end

          it "named the jobs correctly using the test rail run name and an index integer" do
            jobs.each_with_index do |job, index|
              expect(job.job_name).to eq "#{test_rail_run.name} ##{index+1}"
            end
          end

          it "set the queued count for each job correctly" do
            jobs.each do |job|
              expect(job.execution_variables['tests'].count).to eq job.queued_count
            end
          end

          it "stored the tests to be run in the job's execution variables" do
            test_rail_tests.each_slice(batch.tests_per_job).each_with_index do |test_slice, index|
              expected_test_slice = test_slice.collect(&:title)
              expect(jobs[index].execution_variables['tests']).to eq expected_test_slice
            end
          end
        end
      end
    end
  end
end
