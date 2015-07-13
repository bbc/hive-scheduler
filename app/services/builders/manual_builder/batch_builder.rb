module Builders
  class ManualBuilder < Builders::Base
    class BatchBuilder < Builders::BatchBuilderBase

      def build_job_groups(batch)
        queues(batch).collect do |queue|
          JobGroupBuilder.build(batch: batch, queue: queue)
        end
      end

      private

      def queues(batch)
        batch.execution_variables["queues"]
      end

      def project
        @project = Project.find_by_id(project_id)
      end
    end
  end
end
