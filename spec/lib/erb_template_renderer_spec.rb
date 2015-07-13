require "spec_helper"

describe ErbTemplateRenderer do

  describe "#render" do

    let(:template) { File.read("spec/fixtures/files/erb_template.erb") }
    let(:variables) { { "key1" => "value1", "key2" => "value2" } }

    let(:renderer) { ErbTemplateRenderer.new(template, variables) }

    subject { JSON.parse(renderer.render) }

    it { should eq variables }
  end
end
