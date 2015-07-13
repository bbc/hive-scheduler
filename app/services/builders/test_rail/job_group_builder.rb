module Builders
  class TestRail < Builders::Base
    class JobGroupBuilder < Builders::JobGroupBuilderBase

      attribute :test_rail_run, ::TestRail::Run

      validates_presence_of :batch, :test_rail_run

      protected

      def job_group_name
        test_rail_run.name
      end

      def job_group_queue_name
        test_rail_run.config
      end

      def job_group_execution_variables
        { run_id: test_rail_run.id }
      end

      def tests
        @tests ||= test_rail_run.tests.collect(&:title)
      end

      def job_base_name
        test_rail_run.name
      end
    end
  end
end
