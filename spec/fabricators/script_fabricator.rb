module Fabricators
  EXECUTION_TEMPLATE          = "execution template command"
  CUCUMBER_EXECUTION_TEMPLATE = "cucumber execution template command"
end

Fabricator(:script) do
  name { 'Android Calabash' }
  target { Fabricate(:android_target) }
  template { Fabricators::EXECUTION_TEMPLATE }
  execution_variables { [Fabricate.build(:field)] }
end

Fabricator(:cucumber_script, from: :script) do
  name { 'Cucumber Tags' }
  template { Fabricators::CUCUMBER_EXECUTION_TEMPLATE }
  execution_variables { [Fabricate.build(:cucumber_tags_field)] }
end

def cucumber_script
  # Always re-fetch the script in case its been deleted from the db
  @cucumber_script = Script.find_by_id(@cucumber_script.id) if @cucumber_script.present?
  @cucumber_script ||= Fabricate(:cucumber_script)
end
