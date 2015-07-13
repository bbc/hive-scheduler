class Batch < ActiveRecord::Base
  module BatchValidations
    extend ActiveSupport::Concern

    included do

      validates :name, :version, presence: true
      validates_associated :project
    end
  end
end
