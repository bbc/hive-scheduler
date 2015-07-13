require 'spec_helper'

describe JobGroup do
  it { should be_a(JobGroup::JobGroupAssociations)}
  it { should be_a(JobGroup::JobGroupValidations)}

  it { should serialize(:execution_variables).as(::ActiveRecord::Coders::JSON) }
end
