class Job < ActiveRecord::Base
  module JobAssociations
    extend ActiveSupport::Concern

    included do
      belongs_to :job_group
      has_one :batch, through: :job_group
      has_one :project, through: :batch
      has_one :script, through: :project
      has_one :replacement, class_name: "Job", foreign_key: :original_job_id
      belongs_to :original_job, class_name: "Job", foreign_key: :original_job_id
      has_many :artifacts
      has_many :test_cases, through: :test_results
      has_many :test_results
    end
  end
end
