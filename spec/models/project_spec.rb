require 'spec_helper'

describe Project do

  its(:paranoid?) { should be }
  it { should be_a(Project::ProjectValidations) }
  it { should be_a(Project::ProjectAssociations) }
  it { should be_a(Project::ProjectCallbacks) }

  it { should serialize(:builder_options).as(::ActiveRecord::Coders::JSON) }
  it { should serialize(:execution_variables).as(::ActiveRecord::Coders::JSON) }

  describe "delegates" do
    it { should delegate_method(:requires_build?).to(:script) }
    it { should delegate_method(:target).to(:script) }
  end

  describe "instance methods" do

    describe "#execution_variables_required" do

      let(:project) { Project.new(script: script, builder_name: builder_name ) }
      context "no script or builder has been set" do

        let(:script) { nil }
        let(:builder_name) { nil }

        it "provides an empty array" do
          expect(project.execution_variables_required).to be_empty
        end
      end

      context "an script has been set" do

        let(:script) { Fabricate(:script) }
        let(:builder_name) { nil }

        it "just provides the fields form the script" do
          expect(project.execution_variables_required).to eq script.execution_variables
        end
      end

      context "an script and a builder has been set" do

        before(:each) do
          Builders::Registry.register(Builders::TestRail)
        end

        let(:script) { Fabricate(:script) }
        let(:builder_name) { builder.builder_name }
        let(:builder) { Builders::TestRail }

        it "just provides the fields form the script and the builder" do
          expect(project.execution_variables_required | Builders::TestRail.execution_variables_required).to eq (script.execution_variables | builder.execution_variables_required )
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

      it "doesn't allow two projects with the same name" do
        project_1 = Project.create(name: 'Name test', repository: 'repo', script_id: 1, builder_name: 'manual_builder')
        project_2 = Project.create(name: 'Name test', repository: 'repo', script_id: 1, builder_name: 'manual_builder')

        project_1.save
        expect(project_2.save).to eq(false)
      end
    end
  end
end
