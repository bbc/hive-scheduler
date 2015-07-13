module Builders
  class TestRail < Builders::Base
    class BatchBuilder < Builders::BatchBuilderBase

      def build_job_groups(batch)
        test_rail_runs.collect do |test_rail_run|
          Builders::TestRail::JobGroupBuilder.new(batch: batch, test_rail_run: test_rail_run).perform
        end
      end

      private

      def test_rail_runs
        test_rail_plan.runs
      end

      def test_rail_plan
        instance_settings = Chamber.env.test_rail[test_rail_instance]
        ::TestRail.configure do |config|
          config.user      = instance_settings['user']
          config.password  = instance_settings['password']
          config.namespace = test_rail_instance
        end
        ::TestRail::Plan.find_by_id(test_rail_plan_id)
      end

      def test_rail_plan_id
        project.builder_options["test_rail_plan_id"]
      end

      def test_rail_instance
        project.builder_options["test_rail_instance"]
      end

      def project
        @project = Project.find_by_id(project_id)
      end
    end
  end
end
