require "spec_helper"

describe Builders::Validators::BuilderNameValidator do

  describe "#validate_each" do

    let(:model) do
      model_klass = Class.new do
        include ActiveModel::Validations
        attr_accessor :builder_name
      end

      model_instance = model_klass.new
      model_instance.builder_name = model_builder_name
      model_instance
    end


    let(:stub_builder_name) { "stub_builder" }
    let(:stub_builder)      { double(Builders::Base, builder_name: stub_builder_name) }
    let(:validator)         { Builders::Validators::BuilderNameValidator.new(attributes: [:builder_name]) }

    before(:each) do
      Builders::Registry.register(stub_builder)
      validator.validate(model)
    end

    subject { model.errors[:builder_name] }

    context "model has a valid builder_name" do
      let(:model_builder_name) { stub_builder_name }

      it { should be_empty }
    end

    context "model has an INVALID builder_name" do
      let(:model_builder_name) { "invalid_builder_name" }

      it { should_not be_empty }
    end
  end
end
