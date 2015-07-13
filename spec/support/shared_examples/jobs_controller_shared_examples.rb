shared_examples "job not found" do

  let(:expected_error) { "Job not found" }
  let(:response_body) { JSON.parse(response.body) }

  before(:each) do
    send(http_verb, action, parameters)
  end

  let(:response_error) { response_body['error'] }

  it { should respond_with :not_found }
  it "responds with the correct payload error" do
    expect(response_error).to eq expected_error
  end
end

shared_examples "job with errors" do

  let(:errors) { ["something went wrong uploading artifact"] }
  let(:job) { double(Job, acting_method => false, "device_id=".to_sym => nil) }
  let(:job_id) { 77 }
  let(:http_verb) { :put }

  before(:each) do
    Job.stub(find: job)
    job.stub_chain(:errors, :full_messages).and_return(errors)
    send(http_verb, action, params)
  end

  it "fetched the job using the provided job_id" do
    expect(Job).to have_received(:find).with(job_id.to_s)
  end
  it { should respond_with(:unprocessable_entity) }
  it "responds with the error messages in the json body" do
    expect(response_body).to eq({ "errors" => errors })
  end
end
