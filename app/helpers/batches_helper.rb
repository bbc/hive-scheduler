module BatchesHelper
  def additional_variables
    defaults = Builders::Base::SPECIAL_EXECUTION_VARIABLES.keys.map { |a| a.to_s }
    @batch.execution_variables.select { |a| !defaults.include?(a) }
  end
end