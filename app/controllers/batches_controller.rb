class BatchesController < ApplicationController
  before_filter :get_batch, only: [:show, :filter_jobs, :download_build, :chart_data]

  def index
    @filter_query = BatchQueries::Filters.new(params[:search])
    @page    = params[:page] || 1
    @batches = @filter_query.scope.includes(:project, :test_cases, :job_groups => [:test_results]).page(params[:page]).order("created_at desc")
  end

  def filter
    @batches = Batch.includes(:project).where(state: params[:state]).page(params[:page]).order("created_at desc")
    render :index
  end

  def show
    @jobs = @batch.jobs.order(:job_group_id, :job_name).group_by { |j| j.job_group_id }
  end

  def new
    @batch = Batch.new(params[:batch].blank? ? {} : batch_params)
    
    respond_to do |format|
      format.js {}
      format.html {}
    end
  end

  def create
    @batch = BatchCommands::BuildBatchCommand.build(batch_params)
    if @batch.save
      redirect_to @batch, notice: 'Batch was successfully created.'
    else
      render action: 'new'
    end
  end

  def filter_jobs
    @jobs = @batch.jobs.where(state: params[:state]).page(params[:page]).order(:created_at)
    render :show
  end

  def download_build
    redirect_to @batch.build.expiring_url(10*60)
  end

  def chart_data
    @chart_data = @batch.chart_data
  end

  private

  def get_batch
    @batch = Batch.includes(:project).find(params[:id] || params[:batch_id])
  end

  def batch_params
    @batch_params = params.require(:batch).permit! #(:name, :project_id, :version, :build)
    @batch_params[:target_information]  = params[:batch][:target_information]
    @batch_params[:execution_variables] = params[:batch][:execution_variables]
    @batch_params
  end
end
