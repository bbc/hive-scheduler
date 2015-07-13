class Admin::ExecutionTypesController < Admin::AdminController
  before_filter :set_exec_type, only: [:show, :edit, :update, :destroy]

  def index
    @execution_types = ExecutionType.all
  end

  def show;
  end

  def new
    @execution_type = ExecutionType.new
  end

  def create
    @execution_type = ExecutionType.new(exec_type_params)

    if @execution_type.save
      redirect_to admin_execution_types_path, notice: 'Execution Type was successfully created'
    else
      render action: 'new'
    end
  end

  def edit;
  end

  def update
    if @execution_type.update(exec_type_params)
      redirect_to admin_execution_types_path, notice: 'Execution Type was successfully updated'
    else
      render action: 'edit'
    end
  end

  private

  def set_exec_type
    @execution_type = ExecutionType.find(params[:id])
  end

  def exec_type_params
    params.require(:execution_type).permit(
        :target_id,
        :name,
        :template,
        :requires_build,
        target_fields_attributes: [:id, :name, :field_type, :_destroy],
        execution_variables_attributes: [:id, :name, :field_type, :_destroy]
    )
  end
end
