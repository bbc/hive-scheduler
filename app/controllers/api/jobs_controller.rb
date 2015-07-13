class Api::JobsController < Api::ApiController
  include Roar::Rails::ControllerAdditions
  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, with: :render_job_not_found

  before_filter :fetch_job, except: [:reserve, :update_results]

  def show
    render_job_as_message(@job)
  end

  # Methods that cause a job state transition
  
  def reserve
    job = JobCommands::JobReservation.new(queue_names: params[:queue_names].split(","), reservation_details: params[:reservation_details]).perform
    if job.present?
      render_job_as_message(job)
    else
      head status: :not_found
    end
  end

  def prepare
    if @job.prepare(params[:device_id])
      render_job_as_message(@job)
    else
      render_model_with_errors(@job)
    end
  end

  def start
    if @job.start
      render_job_as_message(@job)
    else
      render_model_with_errors(@job)
    end
  end

  def end
    if @job.end(params[:exit_value])
      render_job_as_message(@job)
    else
      render_model_with_errors(@job)
    end
  end

  def update_results
    job = JobCommands::JobResultsUpdater.new(job_result_params.merge(job_id: params[:job_id])).perform
    if job.valid?
      render_job_as_message(job)
    else
      render_model_with_errors(job)
    end
  end

  def complete
    if @job.complete
      render_job_as_message(@job)
    else
      render_model_with_errors(@job)
    end
  end

  def error
    if @job.error(params[:message])
      render_job_as_message(@job)
    else
      render_model_with_errors(@job)
    end
  end

  def report_artifacts
    artifact = @job.artifacts.build(asset: params[:data])

    if artifact.save
      render status: 200, json: { artifact_id: artifact.id }
    else
      render_model_with_errors(artifact)
    end
  end

  private

  def fetch_job
    @job = Job.find(params[:id] || params[:job_id])
  end

  def render_job_as_message(job)
    @job_message = JobCommands::JobMessageMapper.new(job: job).perform
    render json: @job_message
  end

  def job_result_params
    params.permit(:running_count, :passed_count, :failed_count, :errored_count)
  end
end
