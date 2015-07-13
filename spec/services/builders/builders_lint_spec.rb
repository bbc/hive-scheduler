require "spec_helper"

shared_examples "a builder module" do

  describe "module convenience methods" do

    describe ".batch_builder" do

      it "returns Manifest::BATCH_BUILDER" do
        expect(described_class.batch_builder).to eq described_class.const_get(:Manifest).const_get(:BATCH_BUILDER)
      end
    end

    describe ".builder_name" do

      it "returns Manifest::BUILDER_NAME" do
        expect(described_class.builder_name).to eq described_class.const_get(:Manifest).const_get(:BUILDER_NAME)
      end
    end

    describe ".friendly_name" do

      it "returns Manifest::FRIENDLY_NAME" do
        expect(described_class.friendly_name).to eq described_class.const_get(:Manifest).const_get(:FRIENDLY_NAME)
      end
    end
  end

  describe "Manifest" do

    describe "constants" do

      let(:manifest) { described_class.const_get(:Manifest) }

      it "has a name" do
        expect(manifest.const_get(:BUILDER_NAME)).to be_present
      end

      it "has a friendly name" do
        expect(manifest.const_get(:FRIENDLY_NAME)).to be_present
      end

      it "has defined a batch builder" do
        expect(manifest.const_get(:BATCH_BUILDER)).to be_present
      end

      it "has defined a batch builder class" do
        expect(manifest.const_get(:BATCH_BUILDER)).to be_instance_of(Class)
      end
    end
  end
end

Builders::Registry.registered_builders.each do |builder|
  describe builder do
    it_behaves_like "a builder module"
  end
end

