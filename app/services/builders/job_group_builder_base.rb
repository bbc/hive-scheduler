module Builders
  class JobGroupBuilderBase < Imperator::Command

    attribute :batch, Batch

    validates_presence_of :batch

    class << self

      def build(*args)
        new(*args).perform
      end
    end

    action do
      JobGroup.new(job_group_attributes).tap do |job_group|
        job_group.jobs = build_jobs(job_group)
      end
    end

    def build_jobs(job_group)
      if test_slices.count > 1
        test_slices.each_with_index.map do |test_slice, index|
          job_execution_variables = { tests: test_slice, job_index: index+1, total_jobs: test_slices.count }
                    
          job = Job.create(
              job_name:            "#{job_base_name} ##{index+1}",
              queued_count:        test_slice.count,
              execution_variables: job_execution_variables,
              job_group:           job_group
          )
          job.associate_test_cases( *test_slice )
          job
        end
      else
        job = Job.new(
              job_name:            "#{job_base_name}",
               queued_count:        nil,
               execution_variables: {},
               job_group:           job_group)
        
        job.associate_test_cases(*sanitized_tests)
        [job]
      end
    end
    

    def sanitized_tests
      (tests || []).delete_if(&:blank?)
    end

    def test_slices
      @test_slices   ||= if (batch.jobs_per_queue.present? && batch.jobs_per_queue > 0)
                           slices = []
                           batch.jobs_per_queue.to_i.times do
                             slices << sanitized_tests
                           end
                           slices
                         elsif (batch.tests_per_job.present? && batch.tests_per_job > 0)
                           sanitized_tests.each_slice(batch.tests_per_job).to_a
                         else
                           [sanitized_tests]
                         end
      @test_slices
    end

    protected

    def job_group_attributes
      { batch:               batch,
        name:                job_group_name,
        hive_queue:          HiveQueue.find_or_create_by(name: job_group_queue_name),
        execution_variables: job_group_execution_variables
      }
    end

    def job_group_name
      raise NotImplementedError
    end

    def job_group_queue_name
      raise NotImplementedError
    end

    def job_group_execution_variables
      raise NotImplementedError
    end

    def tests
      raise NotImplementedError
    end

    def job_base_name
      raise NotImplementedError
    end
  end
end
