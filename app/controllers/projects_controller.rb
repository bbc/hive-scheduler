class ProjectsController < ApplicationController

  before_action :set_project, only: [:edit, :update, :destroy]
  before_action :set_builders, only: [:edit]

  # GET /projects
  def index
    @projects = Project.all.reverse
  end

  # GET /projects/1
  def show
    @project = Project.find(params[:id])
    @related_projects = @project.script.projects.where( 'id != ?', @project.id )
  end

  # GET /projects/new
  def new
    @project = Project.new(params[:project].blank? ? {} : project_params)
    set_builders

    respond_to do |format|
      format.js {}
      format.html {}
    end
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  def create
    @project = Project.new(project_params)

    if @project.save
      redirect_to @project, notice: 'Project was successfully created.'
    else
      set_builders
      render action: 'new'
    end
  end

  # PATCH/PUT /projects/1
  def update
    if @project.update(project_params)
      redirect_to @project, notice: 'Project was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /projects/1
  def destroy
    @project.destroy
    redirect_to projects_url, notice: 'Project was successfully destroyed.'
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_project
    @project = Project.find_by_id(params[:id])
  end

  def set_builders
    @selected_builder = Builders::Registry.find_by_builder_name(@project.builder_name)
    @builders         = Builders::Registry.registered_builders
  end

  # Only allow a trusted parameter "white list" through.
  def project_params
    if @project_params.nil?
      @project_params = params.require(:project).permit(:name, :platform, :plan_id, :script_id, :builder_name, :repository, :execution_directory, :retries)
      @project_params.merge!(builder_options: params[:project][:builder_options])
      @project_params.merge!(execution_variables: params[:project][:execution_variables])
    end
    @project_params
  end
end
