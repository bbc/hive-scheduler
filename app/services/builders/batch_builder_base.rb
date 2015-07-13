module Builders
  class BatchBuilderBase < Imperator::Command

    attribute :project_id
    attribute :name
    attribute :build
    attribute :version
    attribute :target_information
    attribute :execution_variables

    validates_presence_of :project_id, :name, :build, :version

    class << self

      def build(*args)
        new(*args).perform
      end
    end

    action do
      Batch.new(batch_attributes).tap do |batch|
        batch.job_groups = build_job_groups(batch)
      end
    end

    def build_job_groups(batch)
      raise NotImplementedError
    end

    protected

    def batch_attributes
      {
          project_id:          project_id,
          name:                name,
          build:               build,
          version:             version,
          target_information:  target_information,
          execution_variables: execution_variables

      }
    end
  end
end
