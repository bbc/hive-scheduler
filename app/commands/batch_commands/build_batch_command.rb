module BatchCommands

  class BuildBatchCommand < Imperator::Command

    attribute :project_id, Integer
    attribute :version, String
    attribute :build
    attribute :name, String
    attribute :target_information, Hash
    attribute :execution_variables, Hash
    attribute :generate_name, Boolean, default: false

    validates_presence_of :project_id, :version
    validates_presence_of :name, unless: lambda { |create_batch_command| create_batch_command.generate_name }

    class << self

      def build(*args)
        new(*args).perform
      end
    end

    action do
      builder.batch_builder.build(batch_builder_arguments)
    end

    private

    def builder
      @builder ||= project.builder
    end

    def batch_builder_arguments
      {
          project_id:          project_id,
          name:                new_name,
          build:               save_build,
          version:             version,
          target_information:  target_information,
          execution_variables: processed_execution_variables
      }
    end

    def save_build
      return @build if @build.nil?

      if @build.is_a? ActionDispatch::Http::UploadedFile
        @build = [@build]
      end
      @build.each do |b|
        asset = Asset.find_or_register(project_id: project_id, name: new_name, file: b.original_filename, version: version)
        asset.asset = b
        asset.save
      end
      @build
    end

    def new_name
      @new_name ||= name || derived_name
    end

    def derived_name
      # TODO revisit how this is generated to ensure thread safety and avoid potential collisions
      project.name if generate_name
    end

    def processed_execution_variables
      if @processed_execution_variables.nil?
        @processed_execution_variables = (self.execution_variables || {}).with_indifferent_access
        array_variables               = @processed_execution_variables.slice(*execution_variables_to_be_processed_as_arrays)
        array_variables.each_pair do |key, value|
          @processed_execution_variables[key] = value.is_a?(Array) ? value : value.split(",")
        end
      end
      @processed_execution_variables[:queues] = curated_queues unless @processed_execution_variables[:curated_queue].blank?
      @processed_execution_variables
    end

    def curated_queues
      CuratedQueue.find(execution_variables.with_indifferent_access[:curated_queue]).queues
    end

    def execution_variables_to_be_processed_as_arrays
      project.execution_variables_required.find_all do |execution_field|
        execution_field.field_type.to_sym == :array
      end.collect(&:name)
    end

    def project
      @project ||= Project.find_by_id(project_id)
    end
  end
end
