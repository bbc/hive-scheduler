module JobCommands

  class JobReservation < Imperator::Command

    attribute :queue_names, Array[String]
    attribute :reservation_details

    def queue_names=(queue_names)
      queue_names = queue_names.split(",") unless queue_names.is_a?(Array)
      super(queue_names.collect(&:strip))
    end
    
    def queue_ids
      HiveQueue.where( name: queue_names ).pluck(:id)
    end

    action do
      Job.transaction do
        job = Job.includes(:job_group => [:hive_queue] ).where(state: :queued, job_groups: { hive_queue_id: queue_ids }).order(created_at: :asc).lock(true).first
        if job.present?
          job.reserve(reservation_details)
          raise JobReservationError.new("Job #{job.id}:#{job.job_name}, could not be reserved") unless job.reserved?
          job
        end
      end
    end
  end

  class JobReservationError < StandardError;
  end
end
