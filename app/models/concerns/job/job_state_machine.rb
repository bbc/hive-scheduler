class Job < ActiveRecord::Base
  module JobStateMachine
    extend ActiveSupport::Concern

    included do

      state_machine :state, initial: :queued do

        after_transition to: :reserved do |job, transition|
          reservation_details = transition.args.first
          job.update(reserved_at: Time.now, reservation_details: reservation_details)
          JobCommands::JobReservationCheck.new.async.check_in(Chamber.env.job_reservation_timeout+1.second, job.id)
        end

        after_transition to: :preparing do |job, transition|
          device_id = transition.args.first
          job.update(device_id: device_id)
          JobCommands::StuckRunningJobsChecker.new.async.check_in(Chamber.env.stuck_running_jobs_timeout)
        end

        before_transition to: :preparing, do: :move_queued_to_running
                
        before_transition to: :preparing do |job, transition|
          device_id = transition.args.first
          JobCommands::StuckJobsForDeviceChecker.new(device_id: device_id).perform
        end
        
        before_transition to: :analyzing do |job, transition|
          exit_value = transition.args.first
          job.update(script_end_time: Time.now)
          job.update(exit_value: exit_value)
        end
        
        before_transition to: :errored do |job, transition|
          message = transition.args.first
          job.move_all_to_errored
          job.update(message: message)
        end

        after_transition to: :queued do |job|
          job.update(reservation_details: nil, reserved_at: nil)
        end

        after_transition to: :preparing do |job|
          job.update(start_time: Time.now)
        end

        after_transition to: :running do |job|
          job.update(script_start_time: Time.now)
        end

        after_transition to: [:complete, :errored] do |job|
          job.update(end_time: Time.now)
        end

        before_transition to: :complete do |job|
          job.calculate_result
        end
        
        after_transition to: [:complete, :errored] do |job|
          if job.can_retry?
            JobCommands::AutoJobRetrier.new(job: job).perform
          end
        end
        
        after_transition to: :cancelled, do: :move_all_to_errored

        event :reserve do
          transition queued: :reserved
        end

        event :unreserve do
          transition reserved: :queued
        end
        
        event :prepare do
          transition reserved: :preparing, if: :reservation_valid?
        end

        event :start do
          transition preparing: :running
        end
        
        event :end do
          transition running: :analyzing
        end

        event :complete do
          transition analyzing: :complete
        end

        event :error do
          transition all => :errored
        end
        
        event :cancel do
          transition [:queued, :reserved] => :cancelled
        end
        
        event :uncancel do
          transition cancelled: :queued
        end
        
      end

    end
  end
end
