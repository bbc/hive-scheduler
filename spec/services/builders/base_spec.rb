require "spec_helper"

module Builders
  describe Base do

    describe "class methods" do

      let(:klass) do
        klass    = Class.new(Builders::Base)
        manifest = Module.new
        manifest.const_set(:BATCH_BUILDER, :batch_builder)
        manifest.const_set(:BUILDER_NAME, :builder_name)
        manifest.const_set(:FRIENDLY_NAME, :friendly_name)
        klass.const_set(:Manifest, manifest)
        klass
      end

      describe ".batch_builder" do

        it "returns the implementing classes Manifest::BATCH_BUILDER" do
          expect(klass.batch_builder).to eq :batch_builder
        end
      end

      describe ".builder_name" do

        it "returns the implementing classes Manifest::BUILDER_NAME" do
          expect(klass.builder_name).to eq :builder_name
        end
      end

      describe ".friendly_name" do

        it "returns the implementing classes Manifest::FRIENDLY_NAME" do
          expect(klass.friendly_name).to eq :friendly_name
        end
      end

      describe ".requires" do

        let(:requirements) { { queues: :array, tests: :array } }

        before(:each) do
          klass.requires(requirements)
        end

        let(:stored_dependencies) do
          klass.dependencies.inject({}) do |stored_dependencies, dependency|
            stored_dependencies[dependency.name] = dependency.field_type
            stored_dependencies
          end
        end

        it "creates a Dependency for each requirement" do
          expect(stored_dependencies).to eq(requirements)
        end
      end

      describe ".provides" do

        before(:each) do
          klass.provides(*execution_variables)
        end

        context "single execution variable name provided" do
          let(:execution_variables) { :queues }

          it "stored the single field into the execution_variables_provided array" do
            expect(klass.instance_variable_get(:@execution_variables_provided)).to match_array([execution_variables])
          end
        end

        context "array of execution variables provided" do

          let(:execution_variables) { [:queues, :tests] }

          it "stored the array correctly to execution_variables_provided" do
            expect(klass.instance_variable_get(:@execution_variables_provided)).to match_array(execution_variables)
          end
        end
      end

      describe ".execution_variables_required" do

        let(:required_fields) do
          klass.execution_variables_required.inject({}) do |required_fields, required_field|
            required_fields[required_field.name] = required_field.field_type
            required_fields
          end
        end

        let(:expected_fields) do
          expected_raw_fields.inject({}) do |expected_fields, (name,attributes)|
            expected_fields[name] = attributes[:field_type]
            expected_fields
          end
        end

        context "no execution variables are provided by the builder" do

          let(:expected_raw_fields) { Builders::Base::SPECIAL_EXECUTION_VARIABLES }

          it "returns all of the special execution variables" do
            expect(required_fields).to eq(expected_fields)
          end
        end

        context "the builder provides queues but nothing else" do

          before(:each) do
            klass.provides(:queues)
          end

          let(:expected_raw_fields) { fields_not_provided = Builders::Base::SPECIAL_EXECUTION_VARIABLES.dup.except(:queues) }

          it "returns all of the special execution variables except queues" do
            expect(required_fields).to eq(expected_fields)
          end
        end
      end
    end
  end
end
