module Builders
  class ManualBuilder < Builders::Base
    class JobGroupBuilder < Builders::JobGroupBuilderBase

      attribute :queue, String

      validates_presence_of :queue

      protected

      def job_group_name
        "#{project.name} (#{queue})"
      end

      def job_group_queue_name
        queue
      end

      def job_group_execution_variables
        {}
      end

      def project
        batch.project
      end

      def tests
        batch.execution_variables.with_indifferent_access[:tests]
      end

      def job_base_name
        "#{project.name} (#{queue})"
      end
    end
  end
end
