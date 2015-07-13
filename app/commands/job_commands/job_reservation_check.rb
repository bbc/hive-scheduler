module JobCommands

  class JobReservationCheck
    include SuckerPunch::Job

    def perform(job_id)
      ActiveRecord::Base.connection_pool.with_connection do
        job = Job.find_by_id(job_id)
        job.unreserve unless job.reservation_valid?
      end
    end

    def check_in(seconds, job_id)
      after(seconds) { perform(job_id) }
    end
  end
end
