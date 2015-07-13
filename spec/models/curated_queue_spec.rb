require 'spec_helper'

describe CuratedQueue do

  it { should serialize(:queues).as(::ActiveRecord::Coders::JSON) }
end
