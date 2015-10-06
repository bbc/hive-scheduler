class Batch < ActiveRecord::Base
  module BatchAssociations
    extend ActiveSupport::Concern

    included do

      belongs_to :project, :with_deleted => true
      has_one    :script, through: :project
      has_many   :job_groups, dependent: :destroy
      has_many   :jobs, through: :job_groups
      has_many   :assets, through: :project, foreign_key: 'version'
      
      has_many   :test_cases, through: :project
      
    end
  end
end
