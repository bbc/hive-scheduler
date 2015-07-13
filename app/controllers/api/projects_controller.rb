class Api::ProjectsController < Api::ApiController
  include Roar::Rails::ControllerAdditions
  respond_to :json
  
  def show
    @project = Project.find_by_id(params[:id])
    if @project.present?
      respond_with @project, represent_with: ProjectRepresenter
    else
      render status: :not_found, json: { errors: [t('.not_found')] }
    end
  end
end
