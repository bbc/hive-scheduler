class Job < ActiveRecord::Base
  module JobValidations
    extend ActiveSupport::Concern

    included do

      validates :queued_count,  numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
      validates :running_count, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
      validates :passed_count,  numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
      validates :failed_count,  numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
      validates :errored_count, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

      validates :job_group, presence: true
    end
  end
end
