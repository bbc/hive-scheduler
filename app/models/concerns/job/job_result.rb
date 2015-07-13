class Job < ActiveRecord::Base
  module JobResult
    extend ActiveSupport::Concern
    
    
    def calculate_result
      
      # Default to errored if no results have been reported
      self.result = 'errored'
      
      # Set initial result using the exit value
      if self.exit_value
        if self.exit_value == 0
          self.result = 'passed'
        else
          self.result = 'failed'
        end
      end
      
 
      # If we've got counts, attempt to be a bit smarter
      if self.errored_count.to_i > 0
        self.result = 'errored'
      elsif self.failed_count.to_i > 0
        self.result = 'failed'
      elsif self.passed_count.to_i > 0
        self.result = 'passed'
      end
      
      self.queued_count = 0
      self.running_count = 0
      self.save
    end

    def move_queued_to_running
      self.running_count = self.queued_count
      self.queued_count  = 0
      self.save
    end

    def move_all_to_errored
      self.errored_count = self.queued_count.to_i + self.running_count.to_i
      self.running_count = 0
      self.queued_count  = 0
      self.save
    end

  end
end
