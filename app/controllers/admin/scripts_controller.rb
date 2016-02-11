class Admin::ScriptsController < Admin::AdminController
  before_filter :set_exec_type, only: [:show, :edit, :update, :destroy]

  def index
    @scripts = Script.all.reverse
  end

  def show;
  end

  def new
    @script = Script.new
  end

  def create
    @script = Script.new(exec_type_params)

    if @script.save
      redirect_to admin_scripts_path, notice: 'Script was successfully created'
    else
      render action: 'new'
    end
  end

  def edit;
  end

  def update
    if @script.update(exec_type_params)
      redirect_to admin_scripts_path, notice: 'Script was successfully updated'
    else
      render action: 'edit'
    end
  end

  private

  def set_exec_type
    @script = Script.find(params[:id])
  end

  def exec_type_params
    params.require(:script).permit(
        :target_id,
        :name,
        :template,
        :requires_build,
        target_fields_attributes: [:id, :name, :field_type, :_destroy],
        execution_variables_attributes: [:id, :name, :field_type, :_destroy]
    )
  end
end
