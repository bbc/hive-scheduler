require "spec_helper"

describe Project::ProjectCallbacks do

  let(:project) { Project.new(name: "test", repository: "git://...", execution_directory: ".") }
  subject { project }

  describe "after_initialize" do

    describe "setting builder_options" do
      context "builder_options are nil" do

        it "sets builder_options to an empty hash on initialize" do
          expect(project.builder_options).to eq({})
        end
      end

      context "builder_options where previously persisted as not nil" do

        let(:builder_options) { { "foo" => "bar" } }

        before(:each) do
          project.script  = Fabricate(:script)
          project.builder_options = builder_options
          project.save(validate: false)
          project.reload
        end

        it "reloads the project with the previously persisted builder_options" do
          expect(project.builder_options).to eq(builder_options)
        end
      end
    end
  end
end
