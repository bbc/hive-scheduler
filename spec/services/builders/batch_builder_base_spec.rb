require "spec_helper"

module Builders

  describe BatchBuilderBase do
    include ActionDispatch::TestProcess

    let(:batch_builder_klass) do
      Class.new(Builders::BatchBuilderBase) do
        def build_job_groups(batch)
          []
        end
      end
    end

    let(:batch_builder) { batch_builder_klass.new(builder_args) }

    let(:project_id) { 99 }
    let(:name) { "Batch #{Fabricate.sequence(:batch_number)}" }
    let(:build) { fixture_file_upload("files/android_build.apk", "application/vnd.android.package-archive") }
    let(:version) { Fabricate.sequence(:version_number) }
    let(:execution_variables) { { foo: :bar } }


    let(:builder_args) do
      {
          project_id:          project_id,
          name:                name,
          build:               build,
          version:             version,
          execution_variables: execution_variables
      }
    end

    describe "instance methods" do

      describe "#perform" do

        it "returns a batch" do
          expect(batch_builder.perform).to be_instance_of(Batch)
        end

        describe "the returned batch" do

          let(:batch) { batch_builder.perform }
          subject { batch }

          its(:project_id) { should eq project_id }
          its(:name) { should eq name }
          its(:version) { should eq version }
          its(:execution_variables) { should eq execution_variables }
        end
      end
    end
  end
end
