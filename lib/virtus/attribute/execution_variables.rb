module Virtus
  class Attribute
    class ExecutionVariables < Attribute

      def coerce(values)
        unless values.blank?
          klass = Class.new(Hive::Messages::ExecutionVariablesBase)

          attributes     = klass.attribute_set.collect(&:name)
          new_attributes = values.keys-attributes
          new_attributes.each do |attribute|
            klass.attribute attribute
          end

          klass.new(values)
        end
      end
    end
  end
end
