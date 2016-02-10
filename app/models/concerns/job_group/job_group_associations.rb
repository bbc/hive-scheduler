class JobGroup < ActiveRecord::Base
  module JobGroupAssociations
    extend ActiveSupport::Concern

    included do
      belongs_to :batch
      has_many :jobs, dependent: :destroy
      has_many :test_results, through: :jobs
      belongs_to :hive_queue
    end
    
    
    def queue_name
      self.hive_queue.name  
    end
    
  end
end
