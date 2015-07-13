require 'spec_helper'

describe Project do

  its(:paranoid?) { should be }
  it { should be_a(Project::ProjectValidations) }
  it { should be_a(Project::ProjectAssociations) }
  it { should be_a(Project::ProjectCallbacks) }

  it { should serialize(:builder_options).as(::ActiveRecord::Coders::JSON) }
  it { should serialize(:execution_variables).as(::ActiveRecord::Coders::JSON) }

  describe "delegates" do
    it { should delegate_method(:requires_build?).to(:execution_type) }
    it { should delegate_method(:target).to(:execution_type) }
  end

  describe "instance methods" do

    describe "#execution_variables_required" do

      let(:project) { Project.new(execution_type: execution_type, builder_name: builder_name ) }

      context "no execution type or builder has been set" do

        let(:execution_type) { nil }
        let(:builder_name) { nil }

        it "provides an empty array" do
          expect(project.execution_variables_required).to be_empty
        end
      end

      context "an execution type has been set" do

        let(:execution_type) { Fabricate(:execution_type) }
        let(:builder_name) { nil }

        it "just provides the fields form the execution type" do
          expect(project.execution_variables_required).to eq execution_type.execution_variables
        end
      end

      context "an execution type and a builder has been set" do

        before(:each) do
          Builders::Registry.register(Builders::TestRail)
        end

        let(:execution_type) { Fabricate(:execution_type) }
        let(:builder_name) { builder.builder_name }
        let(:builder) { Builders::TestRail }

        it "just provides the fields form the execution type and the builder" do
          expect(project.execution_variables_required | Builders::TestRail.execution_variables_required).to eq (execution_type.execution_variables | builder.execution_variables_required )
        end
      end
    end

    describe "#builder" do

      before(:each) do
        Builders::Registry.register(Builders::TestRail)
        Builders::Registry.register(Builders::ManualBuilder)
      end

      let(:project) { Project.new(builder_name: Builders::TestRail::Manifest::BUILDER_NAME) }

      it "fetches the correct builder" do
        expect(project.builder).to eq(Builders::TestRail)
      end
    end
  end
end
