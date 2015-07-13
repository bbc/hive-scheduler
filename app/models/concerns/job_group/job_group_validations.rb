class JobGroup < ActiveRecord::Base
  module JobGroupValidations
    extend ActiveSupport::Concern

    included do

      validates :batch, :name, presence: true
      validates_associated :batch
    end
  end
end
