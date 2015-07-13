class Api::ArtifactsController <  Api::ApiController
  include Roar::Rails::ControllerAdditions
  respond_to :json

  before_filter :fetch_job
  rescue_from ActiveRecord::RecordNotFound, with: :render_job_not_found

  def create
    artifact = @job.artifacts.build(asset: params[:data])

    if artifact.save
      render_artifact_as_message(artifact)
    else
      render_model_with_errors(artifact)
    end
  end

  private

  def render_artifact_as_message(artifact)
    @artifact_message = Hive::Messages::Artifact.new(artifact.attributes.merge({artifact_id: artifact.id}))
    render json: @artifact_message
  end

  def fetch_job
    @job = Job.find(params[:id] || params[:job_id])
  end
end
