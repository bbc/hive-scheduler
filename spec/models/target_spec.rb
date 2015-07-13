require 'spec_helper'

describe Target do

  it { should have_many(:fields).dependent(:destroy) }
  it { should have_many(:execution_types) }
end
