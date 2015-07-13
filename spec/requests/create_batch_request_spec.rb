require "spec_helper"

describe 'create batch request' do

  let!(:project) { Fabricate(:test_rail_project) }
  let!(:starting_project_batch_count) { project.batches.count }

  let(:name) { "#{Forgery::Name.first_name}'s Batch" }

  let(:apk_file) { fixture_file_upload("files/robodemo-sample-1.0.1.apk", "application/vnd.android.package-archive") }
  let(:version) { "1.0.1" }
  let(:tests_per_job) { 10 }

  before(:each) do
    post "/batches", batch: {
        build:         apk_file,
        name:          name,
        version:       version,
        project_id:    project.id,
        tests_per_job: tests_per_job,
    }
  end
  let(:hive_queues_setting) { false }

  it "created a new batch" do
    expect(project.batches.count).to eq starting_project_batch_count+1
  end

  it "redirects to the created batch" do
    expect(response.status).to eq 302
  end
end
