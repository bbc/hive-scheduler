module BatchesHelper
  def additional_variables
    defaults = Builders::Base::SPECIAL_EXECUTION_VARIABLES.keys.map { |a| a.to_s }
    params = @batch.execution_variables.select { |a| !defaults.include?(a) }
    params.merge(@batch.target_information) if @batch.target_information
    params
  end
end