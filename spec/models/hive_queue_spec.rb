require 'spec_helper'

describe HiveQueue do
  it "currently just consists of a name field" do
    expect(HiveQueue.create(name: 'myqueue')).to be_a HiveQueue
  end
end
