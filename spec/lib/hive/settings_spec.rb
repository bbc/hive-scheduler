require "spec_helper"

describe Chamber.env do

  it { should be }
  it "points to the correct source" do
    pending 'Something to do with Hive::Settings'
    expect(Chamber.env.source).to eq Rails.root.join("config","settings.yml").to_s
  end
end
