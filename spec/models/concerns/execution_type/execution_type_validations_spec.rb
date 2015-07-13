require 'spec_helper'

describe ExecutionType::ExecutionTypeValidations do

  context 'validates presence' do

    let(:execution_type) { ExecutionType.new }

    before { execution_type.valid?.should be_false }

    it 'should require name' do
      execution_type.errors[:name].should_not be_empty
    end

    it 'should require template' do
      execution_type.errors[:template].should_not be_empty
    end

  end

  context 'strip carriage returns' do

    let(:template_before) { "string with \r\r\n\n carriage returns \r\n" }
    let(:template_after)  { "string with \n\n carriage returns \n" }
    let(:execution_type)  { ExecutionType.new(template: template_before) }

    before { execution_type.valid?.should be_false }

    it 'should strip \r' do
      execution_type.template.should == template_after
    end

  end

end
