require "spec_helper"

describe Project::ProjectValidations do

  let(:project) { Project.new }
  subject { project }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:execution_type) }
  it { should_not validate_presence_of(:repository) }
  it { should validate_presence_of(:execution_directory) }
  it { should validate_presence_of(:builder_name) }

  describe "builder_name" do

    before(:each) do
      project.builder_name = builder_name
      project.valid?
    end

    subject { project.errors[:builder_name] }

    context "builder_name is valid" do
      let(:builder_name) { Builders::Registry.registered_builders.first.builder_name }

      it { should be_empty }
    end

    context "builder_name is NOT valid" do
      let(:builder_name) { "invalid_builder" }

      it { should_not be_empty }
    end
  end

  xit "validates that builder_options are valid from the selected builders required options"
end
