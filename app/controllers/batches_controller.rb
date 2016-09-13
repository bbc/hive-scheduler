class BatchesController < ApplicationController
  before_filter :get_batch, only: [:show, :filter_jobs, :chart_data, :cancel_jobs]

  def index
    # This callback is very expensive, turn it off when execution_variables aren't important
    Project.skip_callback( :initialize, :after, :set_default_execution_variables )
    @filter_query = BatchQueries::Filters.new(params[:search])
    @page    = params[:page] || 1
    @batches = @filter_query.scope.includes(:project, :test_cases, :job_groups => [:test_results]).page(params[:page]).order("created_at desc")
  end

  def filter
    @batches = Batch.includes(:project).where(state: params[:state]).page(params[:page]).order("created_at desc")
    render :index
  end

  def show
    if params[:view] == "artifacts"
      @artifacts = {}
      @batch.jobs.each do |j|
        j.images.each do |i|
          name = i[0]
          file = i[1]
          @artifacts[name] = {} if !@artifacts[name]
          @artifacts[name][j.job_group.queue_name] = file
        end
      end
      render :template => "batches/artifacts_view", :layout => 'scrollspy_menu'
    
    # Default view
    else
      @jobs = @batch.jobs.order(:job_group_id, :job_name).group_by { |j| j.job_group_id }
      render :layout => 'scrollspy_menu'
    end
  end

  def cancel_jobs
    @batch.jobs.queued.each do |j|
      j.cancel! 
    end
    redirect_to @batch, notice: "Queued jobs cancelled"
  end

  def new
    @batch = Batch.new(params[:batch].blank? ? {} : batch_params)
    
    respond_to do |format|
      format.js {}
      format.html {}
    end
  end

  def create
    if batch_params['project_id'].empty?
      @batch = Batch.new(params[:batch].blank? ? {} : batch_params)
      render action: 'new'
    else
      @batch = BatchCommands::BuildBatchCommand.build(batch_params)
      if @batch.save
        redirect_to @batch, notice: 'Batch was successfully created.'
      else
        # Required as job_groups is a generated required parameter and so shouldn't be displayed
        @batch.errors.messages.reject! {|k,v| k == :job_groups }
        render action: 'new'
      end
    end
  end

  def filter_jobs
    @jobs = @batch.jobs.where(state: params[:state]).page(params[:page]).order(:created_at)
    render :show
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
