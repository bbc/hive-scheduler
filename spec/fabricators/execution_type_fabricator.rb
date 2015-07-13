module Fabricators
  EXECUTION_TEMPLATE          = "execution template command"
  CUCUMBER_EXECUTION_TEMPLATE = "cucumber execution template command"
end

Fabricator(:execution_type) do
  name { 'Android Calabash' }
  target { Fabricate(:android_target) }
  template { Fabricators::EXECUTION_TEMPLATE }
  execution_variables { [Fabricate.build(:field)] }
end

Fabricator(:cucumber_execution_type, from: :execution_type) do
  name { 'Cucumber Tags' }
  template { Fabricators::CUCUMBER_EXECUTION_TEMPLATE }
  execution_variables { [Fabricate.build(:cucumber_tags_field)] }
end

def cucumber_execution_type
  # Always re-fetch the execution type in case its been deleted from the db
  @cucumber_execution_type = ExecutionType.find_by_id(@cucumber_execution_type.id) if @cucumber_execution_type.present?
  @cucumber_execution_type ||= Fabricate(:cucumber_execution_type)
end
