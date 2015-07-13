require 'spec_helper'

describe Batch::BatchAssociations do

  let(:batch) { Batch.new }
  subject { batch }

  it { should belong_to(:project) }
  it { should have_one(:execution_type).through(:project) }
  it { should have_many(:job_groups).dependent(:destroy) }
  it { should have_many(:jobs).through(:job_groups) }
end
