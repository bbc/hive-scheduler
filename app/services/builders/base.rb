module Builders
  class Base

    SPECIAL_EXECUTION_VARIABLES = {
        queues:         { required: true, field_type: :array, description: "List of queues that tests should be run on", default_value: [""] },
        curated_queue:  { required: true, field_type: :curated_queue, description: "A curated list of queues", default_value: nil },
        tests:          { required: false, field_type: :array, description: "List of tests to be run", default_value: [""] },
        tests_per_job:  { required: false, field_type: :integer, description: "The number of tests to be run per job", default_value: "10" },
        jobs_per_queue: { required: false, field_type: :integer, description: "The number of jobs to create per queue (overrides tests_per_job)", default_value: nil },
        retries:        { required: false, field_type: :integer, description: 'The number of automatic retry attempts', default_value: Chamber.env.maximum_auto_retries},
        job_timeout:    { required: false, field_type: :integer, description: 'Minutes a job can run before it is killed', default_value: 120}
    }

    class << self

      attr_accessor :dependencies, :execution_variables_provided

      def batch_builder
        manifest.const_get(:BATCH_BUILDER)
      end

      def builder_name
        manifest.const_get(:BUILDER_NAME)
      end

      def friendly_name
        manifest.const_get(:FRIENDLY_NAME)
      end

      def manifest
        const_get(:Manifest)
      end

      def requires(requirements)
        self.dependencies = []
        requirements.each_pair do |dependency_name, dependency_type|
          self.dependencies << Field.new(name: dependency_name, field_type: dependency_type)
        end
      end

      def execution_variables_required
        if @required_execution_variables.nil?
          @required_execution_variables = special_execution_variables_not_provided.collect do |name, attributes|
            Field.new(name: name, field_type: attributes[:field_type], default_value: attributes[:default_value])
          end
        end
        @required_execution_variables
      end

      def provides(*fields)
        self.execution_variables_provided = fields
      end

      private

      def special_execution_variables_not_provided
        Builders::Base::SPECIAL_EXECUTION_VARIABLES.dup.except(*execution_variables_provided)
      end
    end
  end
end
