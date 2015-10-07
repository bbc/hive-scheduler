require "spec_helper"

describe Builders::JobGroupBuilderBase do

  describe "validations" do

    let(:builder_args) { nil }

    it { should validate_presence_of(:batch) }
  end

  describe "instance methods" do

    let(:job_group_builder_klass) do

      Class.new(Builders::JobGroupBuilderBase) do
        def job_group_name
          "job_group_name"
        end

        def job_group_queue_name
          "job_group_queue_name"
        end

        def job_group_execution_variables
          {}
        end
      end
    end

    let(:job_group_builder) { job_group_builder_klass.new(batch: batch) }

    describe "#perform" do

      let(:tests_per_job) { "2" }
      let(:jobs_per_queue) { nil }

      let(:batch) { Fabricate(:batch, execution_variables: { "tests_per_job" => tests_per_job, "jobs_per_queue" => jobs_per_queue, "tests" => tests }) }
      let(:tests) { %w(test1 test2 test3 test4) }
      let(:job_base_name) { "Job" }

      before(:each) do
        job_group_builder.stub(tests: tests)
        job_group_builder.stub(job_base_name: job_base_name)
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
        its(:queue_name) { should eq "job_group_queue_name" }
        its(:name) { should eq "job_group_name" }

        describe "the job groups execution_variables" do

          it "stores the test rail run id" do
            expect(job_group.execution_variables).to eq({})
          end
        end

        describe "the jobs in the job group" do

          let(:jobs) { job_group.jobs }

          context "jobs have been sliced with tests_per_job" do

            context "when tests have been provided" do

              it "correctly sliced the tests up into the correct number of jobs" do
                expect(jobs.size).to eq tests.size/batch.tests_per_job
              end

              it "named the jobs correctly using the job base name and job count" do
                jobs.each_with_index do |job, index|
                  expect(job.job_name).to eq "#{job_base_name} ##{index+1}"
                end
              end

              it "set the queued count for each job correctly" do
                jobs.each do |job|
                  expect(job.execution_variables['tests'].count).to eq job.queued_count
                end
              end

              it "stored the tests to be run in the job's execution variables" do
                tests.each_slice(tests_per_job.to_i).each_with_index do |expected_test_slice, index|
                  expect(jobs[index].execution_variables['tests']).to eq expected_test_slice
                end
              end
            end

            context "when NO tests have been provided" do

              let(:tests) { [""] }
              let(:single_job) { jobs.first }

              it "creates a single job" do
                expect(jobs.size).to eq 1
              end

              it "does not number the job name" do
                expect(single_job.job_name).to eq job_base_name
              end

              it "set the queued count for the single job to nil as it is unknown" do
                expect(single_job.queued_count).to be_nil
              end
            end
          end

          context "jobs have been sliced with jobs_per_queue" do

            let(:jobs_per_queue) { 4 }

            it "creates the specified number of jobs" do
              expect(jobs.size).to eq jobs_per_queue
            end

            it "creates each job with the full suite of tests (so the daemon can chop them up as it needs to)" do
              jobs.each do |job|
                expect(job.execution_variables['tests']).to eq tests
              end
            end

            it "provides each job information about what job number it is out of how many" do
              jobs.each_with_index do |job, index|
                expect(job.execution_variables['job_index']).to eq(index+1)
                expect(job.execution_variables['total_jobs']).to eq(jobs.to_a.count)
              end
            end
          end
        end
      end
    end
  end
end
