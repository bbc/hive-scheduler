require "spec_helper"

module BatchCommands
  describe BuildBatchCommand do

    describe "validations" do
      it { should validate_presence_of(:project_id) }
      it { should validate_presence_of(:version) }

      describe "name validation" do

        subject { BatchCommands::BuildBatchCommand.new(generate_name: generate_name) }

        context "generate_name is true" do

          let(:generate_name) { true }
          it { should_not validate_presence_of(:name) }
        end

        context "generate_name is false" do

          let(:generate_name) { false }

          it { should validate_presence_of(:name) }
        end
      end
    end

    describe "class methods" do

      describe ".build" do

        let(:batch_builder_command) { double(BatchCommands::BuildBatchCommand, perform: :batch) }

        before(:each) do
          BatchCommands::BuildBatchCommand.stub(new: batch_builder_command)
        end

        let!(:resulting_batch) { BatchCommands::BuildBatchCommand.build(:build_args) }

        it "instantiates a builder instance using the provided arguments" do
          expect(BatchCommands::BuildBatchCommand).to have_received(:new).with(:build_args)
        end

        it "delegates batch building to BatchCommands::BuildBatchCommand#peform" do
          expect(batch_builder_command).to have_received(:perform)
        end

        it "returns the value passed back from BatchCommands::BuildBatchCommand#peform" do
          expect(resulting_batch).to eq :batch
        end
      end
    end

    describe "instance methods" do

      describe "#perform" do

        before(:each) do

          test_builder               = Module.new
          test_builder_batch_builder = Class.new
          test_builder.const_set(:BatchBuilder, test_builder_batch_builder)

          test_builder_manifest = Module.new
          test_builder_manifest.const_set(:NAME, builder_name)
          test_builder_manifest.const_set(:FRIENDLY_NAME, "Test Builder")
          test_builder_manifest.const_set(:BATCH_BUILDER, test_builder_batch_builder)
          test_builder.const_set(:Manifest, test_builder_manifest)

          ::Builders.send(:remove_const, :TestBuilder) if defined? Builders::TestBuilder
          ::Builders.const_set(:TestBuilder, test_builder)

          test_builder.stub(batch_builder: test_builder_batch_builder)
          test_builder.stub(execution_variables_required: execution_variables_required)

          Builders::Registry.stub(find_by_builder_name: test_builder)
          Builders::TestBuilder::BatchBuilder.stub(build: batch_stub)

          Builders::Validators::BuilderNameValidator.any_instance.stub(validate_each: nil)
        end

        let(:builder_name) { "test_builder" }

        let(:project) { Fabricate(:project, builder_name: builder_name) }

        let(:project_id) { project.id }
        let(:version) { "#{Fabricate.sequence(:version_number)}" }
        let(:target_information) { { location_url: "http://www.bbc.co.uk" } }
        let(:execution_variables) { { ex_var_one: "ex_var_one" } }
        let(:build) { [ Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/android_build.apk"), 'application/vnd.android.package-archive', false) ] }

        let(:execution_variables_required) { [] }


        let(:batch_attributes) do
          {
              project_id:          project.id,
              version:             version,
              build:               build,
              name:                name,
              generate_name:       generate_name,
              target_information:  target_information,
              execution_variables: execution_variables

          }
        end

        let(:batch_stub) { double(Batch, save: nil, save!: nil) }

        let(:build_batch_command) { BatchCommands::BuildBatchCommand.new(batch_attributes) }

        let!(:batch) { build_batch_command.perform }

        context "name is provided" do

          let(:generate_name) { false }
          let(:name) { "Batch #{Fabricate.sequence(:batch_number)}" }


          let(:expected_batch_builder_arguments) do
            {
                project_id:          project_id,
                name:                name,
                build:               build,
                version:             version,
                target_information:  target_information,
                execution_variables: execution_variables.with_indifferent_access

            }
          end

          it "used the Builders::Registry to determine the correct builder for the project" do
            expect(Builders::Registry).to have_received(:find_by_builder_name).with(builder_name).exactly(2).times
          end

          it "delegated building of the batch to the batch builder using the provided arguments" do
            expect(Builders::TestBuilder::BatchBuilder).to have_received(:build).with(expected_batch_builder_arguments)
          end

          it "returns the batch built by the batch builder" do
            expect(batch).to eq batch_stub
          end

          it "does not attempt to persist the batch" do
            expect(batch_stub).to_not have_received(:save)
            expect(batch_stub).to_not have_received(:save!)
          end
        end

        context "name is nil" do
          let(:name) { nil }

          context "generate_name is true" do
            let(:generate_name) { true }
            let(:expected_name) { project.name }

            let(:expected_batch_builder_arguments) do
              {
                  project_id:          project_id,
                  name:                expected_name,
                  build:               build,
                  version:             version,
                  target_information:  target_information,
                  execution_variables: execution_variables.with_indifferent_access
              }
            end

            it "generates a batch name before delegation to the batch builder" do
              expect(Builders::TestBuilder::BatchBuilder).to have_received(:build).with(expected_batch_builder_arguments)
            end

            it "returns the batch built by the batch builder" do
              expect(batch).to eq batch_stub
            end

            it "does not attempt to persist the batch" do
              expect(batch_stub).to_not have_received(:save)
              expect(batch_stub).to_not have_received(:save!)
            end
          end

          context "generate_name is false" do
            let(:generate_name) { false }
            let(:expected_name) { nil }

            let(:expected_batch_builder_arguments) do
              {
                  project_id:          project_id,
                  name:                expected_name,
                  build:               build,
                  version:             version,
                  target_information:  target_information,
                  execution_variables: execution_variables.with_indifferent_access
              }
            end

            it "generates a batch name before delegation to the batch builder" do
              expect(Builders::TestBuilder::BatchBuilder).to have_received(:build).with(expected_batch_builder_arguments)
            end

            it "returns the batch built by the batch builder" do
              expect(batch).to eq batch_stub
            end

            it "does not attempt to persist the batch" do
              expect(batch_stub).to_not have_received(:save)
              expect(batch_stub).to_not have_received(:save!)
            end
          end
        end

        context "the builder requires queues and tests to be provided as execution_variables" do

          let(:execution_variables_required) do
            [
                Field.new(name: "cucumber_tags", field_type: "string"),
                Field.new(name: "queues", field_type: "array"),
                Field.new(name: "tests", field_type: "array")
            ]
          end

          let(:queues) { %w(queue_one queue_two queue_three) }
          let(:tests) { %w(test_one test_two test_three) }
          let(:name) { "Batch #{Fabricate.sequence(:batch_number)}" }
          let(:generate_name) { true }

          let(:expected_batch_builder_arguments) do
            {
                project_id:          project_id,
                name:                name,
                build:               build,
                version:             version,
                target_information:  target_information,
                execution_variables: { "queues" => queues, "tests" => tests, "cucumber_tags" => "tags" }
            }
          end

          context "execution_variables include comma separated values" do

            let(:execution_variables) do
              {
                  "queues"        => queues.join(","),
                  "tests"         => tests.join(","),
                  "cucumber_tags" => "tags"
              }
            end

            it "rebuilds the comma separated execution_variables back into arrays" do
              expect(Builders::TestBuilder::BatchBuilder).to have_received(:build).with(expected_batch_builder_arguments)
            end
          end

          context "execution_variables are provided as arrays" do

            let(:execution_variables) do
              {
                  "queues"        => queues,
                  "tests"         => tests,
                  "cucumber_tags" => "tags"
              }
            end

            it "rebuilds the comma separated execution_variables back into arrays" do
              expect(Builders::TestBuilder::BatchBuilder).to have_received(:build).with(expected_batch_builder_arguments)
            end
          end

          context "a curated queue has been specified" do

            let(:curated_queues) { %w(curated_queue1, curated_queue2, curated_queue3) }
            let(:curated_queue) { CuratedQueue.create(name: "test queue", queues: curated_queues) }

            let(:execution_variables) do
              {
                  "queues"        => queues,
                  "tests"         => tests,
                  "cucumber_tags" => "tags",
                  "curated_queue" => curated_queue.id
              }
            end

            let(:expected_batch_builder_arguments) do
              {
                  project_id:          project_id,
                  name:                name,
                  build:               build,
                  version:             version,
                  target_information:  target_information,
                  execution_variables: { "queues" => curated_queues, "tests" => tests, "cucumber_tags" => "tags" , "curated_queue" => curated_queue.id}
              }
            end

            it "replaces the list of queues with the curated queues" do
              expect(Builders::TestBuilder::BatchBuilder).to have_received(:build).with(expected_batch_builder_arguments)
            end
          end
        end
      end
    end
  end
end
