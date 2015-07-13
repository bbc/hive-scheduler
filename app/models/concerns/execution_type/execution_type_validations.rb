class ExecutionType < ActiveRecord::Base
  module ExecutionTypeValidations
    extend ActiveSupport::Concern

    included do

      validates :name, :template, presence: true
      before_validation :strip_carriage_returns

    end

    private

      def strip_carriage_returns
        self.template = self.template.to_s.gsub(/\r/, '')
      end

  end
end
