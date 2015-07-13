require 'spec_helper'

describe ExecutionType do

  it { should be_a(ExecutionType::ExecutionTypeValidations) }

  it { should belong_to(:target) }
  it { should have_many(:projects) }
  it { should have_many(:target_fields).class_name("Field").through(:target) }
  it { should have_many(:execution_variables).class_name("Field").dependent(:destroy) }
  it { should_not validate_presence_of(:execution_variables) }
  it { should validate_presence_of(:target) }

  it { should accept_nested_attributes_for(:execution_variables).allow_destroy(true) }

  it { should delegate_method(:requires_build?).to(:target) }
end
