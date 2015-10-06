require 'spec_helper'

describe Script::ScriptValidations do

  context 'validates presence' do

    let(:script) { Script.new }

    before { script.valid?.should be_false }

    it 'should require name' do
      script.errors[:name].should_not be_empty
    end

    it 'should require template' do
      script.errors[:template].should_not be_empty
    end

  end

  context 'strip carriage returns' do

    let(:template_before) { "string with \r\r\n\n carriage returns \r\n" }
    let(:template_after)  { "string with \n\n carriage returns \n" }
    let(:script)  { Script.new(template: template_before) }

    before { script.valid?.should be_false }

    it 'should strip \r' do
      script.template.should == template_after
    end

  end

end
