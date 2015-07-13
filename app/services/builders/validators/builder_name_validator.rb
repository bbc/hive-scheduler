module Builders
  module Validators
    class BuilderNameValidator < ActiveModel::EachValidator

      def validate_each(record, attribute, value)
        if Builders::Registry.find_by_builder_name(value).nil?
          record.errors[attribute] << (options[:message] || "is not a valid builder")
        end
      end
    end
  end
end
