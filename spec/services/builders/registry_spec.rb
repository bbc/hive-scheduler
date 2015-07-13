require "spec_helper"

module Builders
  describe Registry do
    include BuilderHelpers

    describe "class methods" do

      before(:each) do
        Builders::Registry.instance_variable_set(:@registered_builders, nil)
      end

      let(:valid_builder) { valid_builder_klass }

      describe ".register" do

        context "a valid builder is registered" do

          before(:each) do
            Builders::Registry.register(valid_builder)
          end

          it "adds the valid builder to the list of registered builders" do
            expect(Builders::Registry.registered_builders).to include valid_builder
          end
        end
      end

      describe ".find_by_builder_name" do

        context "builders have been registered" do
          before(:each) do
            Builders::Registry.register(valid_builder)
          end

          subject { Builders::Registry.find_by_builder_name(builder_name_to_fetch) }

          context "builder to fetch is registered" do
            let(:builder_name_to_fetch) { valid_builder.builder_name }

            it { should eq valid_builder }
          end

          context "builder to fetch is NOT registered" do
            let(:builder_name_to_fetch) { "invalid_builder" }

            it { should be_nil }
          end
        end

        context "no builders have been registered" do

          it "raises a NoBuildersRegisteredError" do
            expect { Builders::Registry.find_by_builder_name(valid_builder.builder_name) }.to raise_error(Builders::NoBuildersRegisteredError)
          end
        end
      end
    end
  end
end
