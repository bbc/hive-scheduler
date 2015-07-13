require "spec_helper"

describe 'create API batch request' do

  let!(:project) { Fabricate(:manual_project) }
  let!(:starting_project_batch_count) { project.batches.count }

  let(:target_information) { { application_url: "http://bbc.hive", application_url_parameters: "thing=value" } }

  let(:apk_file) { fixture_file_upload("files/robodemo-sample-1.0.1.apk", "application/vnd.android.package-archive") }
  let(:version) { "1.0.1" }
  let(:tests_per_job) { 10 }

  let(:queues) { %w(queue_one queue_two queue_three) }
  let(:tests) { %w(test_one test_two test_three) }

  let(:posted_execution_variables) do
    {
        "queues"        => queues.join(","),
        "tests"         => tests.join(","),
        "cucumber_tags" => "tags"
    }
  end

  let(:expected_execution_variables) do
    {
        "queues"         => queues,
        "tests"          => tests,
        "cucumber_tags"  => "tags",
        "tests_per_job"  => 10,
        "curated_queue"  => nil,
        "jobs_per_queue" => nil
    }
  end

  before(:each) do
    post "/api/batches", {
        project_id:          project.id,
        version:             version,
        build:               apk_file,
        target_information:  target_information,
        execution_variables: posted_execution_variables
    }
  end
  let(:hive_queues_setting) { false }

  it "created a new batch" do
    expect(project.batches.count).to eq starting_project_batch_count+1
  end

  it "responded with success status" do
    expect(response.status).to eq 201
  end

  it "responded with a JSON response containing the batch_id" do
    response_as_hash = JSON.parse(response.body)
    batch            = Batch.last
    expect(response_as_hash).to eq(batch.attributes.slice("id", "name", "version").merge({ "state" => batch.state.to_s }))
  end

  describe "the created batch" do

    it "assigned the provided target parameters to the batch" do
      batch = Batch.last
      expect(batch.target_information).to eq target_information.stringify_keys
    end

    it "assigned the execution variables to the batch" do
      batch = Batch.last
      expect(batch.execution_variables).to eq expected_execution_variables.stringify_keys
    end
  end
end
