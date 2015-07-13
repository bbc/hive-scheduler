module BatchJobGroupRepresenter
  include Roar::JSON
  
  property :id  
  property :name  
  property :state  
  property :version
  
  collection :job_groups do
    property :id
    property :queue_name
    property :status
    collection :jobs do
      property :id
      property :job_name
      property :queued_count
      property :running_count
      property :passed_count
      property :failed_count
      property :errored_count
      property :original_job_id
      property :message
      property :exit_value
      property :status
      
      property :device_id, as: :device, getter: lambda { |args|
        device_name
      }
    end
  end
  
end
