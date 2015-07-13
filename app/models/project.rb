class Project < ActiveRecord::Base
  include ProjectValidations
  include ProjectAssociations
  include ProjectCallbacks
  acts_as_paranoid

  serialize :builder_options, JSON
  serialize :execution_variables, JSON

  delegate :requires_build?, :target, to: :execution_type, allow_nil: true

  after_initialize :set_default_execution_variables

  def set_default_execution_variables
    self.execution_variables = HashWithIndifferentAccess.new unless self.execution_variables.present?
    execution_variables_required.each do |required_execution_variable|
      self.execution_variables[required_execution_variable.name.to_s] = required_execution_variable.default_value unless self.execution_variables[required_execution_variable.name.to_s].present?
    end
  end

  def execution_variables_required
    if @execution_variables_required.nil?
      @execution_variables_required = []
      @execution_variables_required = @execution_variables_required | execution_type.execution_variables if execution_type.present?
      @execution_variables_required = @execution_variables_required | builder.execution_variables_required if builder.present?
    end
    @execution_variables_required
  end

  def builder
    @builder ||= Builders::Registry.find_by_builder_name(self.builder_name)
  end
  
  def latest_batch
    self.batches.last
  end
  
end
