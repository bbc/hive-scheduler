class Api::BatchesController < Api::ApiController
  before_filter :fetch_project, only: [:create]
  include Roar::Rails::ControllerAdditions
  respond_to :json

  # == Create a batch from Jenkins
  #
  # Params:
  #
  #  version    # Version of APK file
  #  build      # APK file
  #  project_id # ID of Hive project batch should be associated with
  #
  def create
    version            = params[:version]
    build              = params[:build]
    tests_per_job      = params[:tests_per_job] || 10
    target_information = params[:target_information]
    # The values for these can be comma separated to make posting from cURL and clients easier
    execution_variables = params[:execution_variables] || {}
    execution_variables["tests_per_job"] = tests_per_job unless execution_variables["tests_per_job"].present?

    @batch = BatchCommands::BuildBatchCommand.build(
        project_id:          @project.id,
        version:             version,
        build:               build,
        generate_name:       true,
        tests_per_job:       tests_per_job,
        target_information:  target_information,
        execution_variables: execution_variables
    )
    
    if @batch.save
      respond_with @batch, represent_with: BatchRepresenter
    else
      render_model_with_errors(@batch)
    end
  end

  def show
    @batch = Batch.find_by_id(params[:id])
    if @batch.present?
      respond_with @batch, represent_with: BatchJobGroupRepresenter
    else
      render status: :not_found, json: { errors: [t('.not_found')] }
    end
  end

  def index
    page     = params[:page] || 1
    per_page = params[:per_page] || 20
    batches  = Batch.includes(:project).paginate(page: page, per_page: per_page).order("created_at desc").to_a
    respond_with batches, represent_items_with: BatchRepresenter
  end

  # == Download build APK file from S3
  #
  # Params:
  #
  #  batch_id   # ID of batch for loacted build asset
  #
  def download_build
    batch = Batch.find_by_id(params[:batch_id])
    if batch.present?
      redirect_to batch.build.expiring_url(10*60)
    else
      render status: :not_found, json: { errors: [t('.not_found')] }
    end
  end

  private

  def fetch_project
    @project = Project.find_by_id(params[:project_id])
    unless @project
      render status: :not_found, json: { errors: [t('.project_not_found')] }
    end
  end
end
