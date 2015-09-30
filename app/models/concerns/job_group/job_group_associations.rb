class JobGroup < ActiveRecord::Base
  module JobGroupAssociations
    extend ActiveSupport::Concern

    included do
      belongs_to :batch
      has_many :jobs, dependent: :destroy
      has_many :test_results, through: :jobs
    end
  end
end
