class Worker < ActiveRecord::Base
  
  has_and_belongs_to_many :hive_queues
  
  scope :active, -> { where( "updated_at > ?", 2.minutes.ago ) }
  
  def self.identify( reservation_details, queue_names )
    
    worker = Worker.includes(:hive_queues).find_or_create_by(
                                      hive_id: reservation_details["hive_id"],
                                      pid: reservation_details["worker_pid"],
                                      device_id: reservation_details["device_id"]
                                     )
    
    worker.associate_queues( queue_names ) if worker.hive_queues.collect{ |q| q.name }.sort != queue_names.sort
    
    worker.touch if (Time.now - worker.updated_at) > 60
    worker
  end
  
  def associate_queues( queue_names )
    queues = queue_names.collect do |q|
      HiveQueue.find_or_create_by( name: q )
    end
    
    self.update( hive_queues: queues )
  end
  
  def status
    if updated_at < Time.now() - 2.minutes
      :inactive
    else
      :active
    end
  end
  
end
