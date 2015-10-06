require "spec_helper"

describe Project::ProjectAssociations do

  subject { Project.new }

  it { should belong_to(:script) }
  it { should have_many(:batches) }
end
