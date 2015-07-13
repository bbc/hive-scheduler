require 'spec_helper'

describe Field do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:field_type) }
  it { should belong_to(:owner) }
end
