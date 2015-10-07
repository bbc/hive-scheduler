module Builders

  class NoBuildersRegisteredError < StandardError
  end

  class Registry

    class << self

      def registered_builders
        if @registered_builders.blank?
          	Builders::Registry.register(Builders::TestRail)
          	Builders::Registry.register(Builders::ManualBuilder)
        end
        @registered_builders.values unless @registered_builders.blank?
      end

      def register(builder)
        @registered_builders = {} if @registered_builders.blank?
        @registered_builders[builder.builder_name] = builder
      end

      def find_by_builder_name(name)
        raise NoBuildersRegisteredError if registered_builders.blank?
        @registered_builders[name]
      end
    end
  end
end
