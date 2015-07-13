require "spec_helper"

describe Virtus::Attribute::ExecutionVariables do

  let(:model_klass) do
    klass = Class.new do
      include Virtus.model

      attribute :execution_variables, Virtus::Attribute::ExecutionVariables
    end
  end

  let(:model) { model_klass.new(execution_variables: values) }
  let(:execution_variables) { model.execution_variables }

  context "values are empty" do

    let(:values) { {} }

    it "returned nil for the execution_variables" do
      expect(execution_variables).to be_nil
    end
  end

  context "values just contain job_ib and version" do

    let(:job_id) { 99 }
    let(:version) { "one" }
    let(:values) { { job_id: job_id, version: version } }

    subject { execution_variables }

    it { should be_a(Hive::Messages::ExecutionVariablesBase) }
    its(:job_id) { should eq job_id }
    its(:version) { should eq version }
  end

  context "values contain extra attributes" do

    let(:job_id)  { 99 }
    let(:version) { "one" }
    let(:foo)     { "foo_value" }
    let(:values)  { { job_id: job_id, version: version, foo: foo } }
    subject { execution_variables }

    it { should be_a(Hive::Messages::ExecutionVariablesBase) }
    its(:job_id) { should eq job_id }
    its(:version) { should eq version }

    it "created a new 'foo' attribute on the anonymous class that was not set on the base ExecutionVariables class" do
      attributes = execution_variables.class.attribute_set.collect(&:name)
      expect(attributes).to include(:foo)
    end

    it "set the value of the 'foo' variable" do
      expect(execution_variables.foo).to eq foo
    end
  end
end

