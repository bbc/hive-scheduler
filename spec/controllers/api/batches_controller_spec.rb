require "spec_helper"

describe Api::BatchesController do

  describe "POST #create" do

    let(:version) { '1' }
    let(:tests_per_job) { "11" }
    let(:params) { { format: :json, project_id: project_id, version: version, tests_per_job: tests_per_job, build: :build } }
    let(:batch) { Fabricate(:batch) }

    before(:each) do
      BatchCommands::BuildBatchCommand.stub(build: batch)
      post :create, params
    end

    context "invalid project_id provided" do
      let(:project_id) { -99 }
      let(:response_body) { JSON.parse(response.body) }

      it { should respond_with(:not_found) }
      it "responds with the error messages in the json body" do
        expect(response_body).to eq({ "errors" => ["Project not found"] })
      end
    end

    context "valid project id provided" do
      let(:project_id) { Fabricate(:project).id }


      context "batch created successfully" do

        it "rendered using the BatchRepresenter" do
          batch = assigns(:batch)
          BatchRepresenter.prepare(batch)
          expect(response.body).to eq batch.to_json
        end
        let(:batch) { Fabricate.build(:batch) }
        it { should respond_with(:created) }
      end

      context "batch has errors" do

        let(:batch) { double(Batch, save: false, errors: errors) }
        let(:errors) { double(ActiveModel::Errors, full_messages: error_messages) }
        let(:error_messages) { ["An error occurred", "There was a problem"] }
        let(:response_body) { JSON.parse(response.body) }

        it { should respond_with(:unprocessable_entity) }
        it "responds with the error messages in the json body" do
          expect(response_body).to eq({ "errors" => error_messages })
        end
      end
    end
  end

  describe 'GET #show' do

    before(:each) do
      get :show, id: batch_id, format: :json
    end

    context "batch_id is for a valid batch" do
      let(:batch) { Fabricate(:batch) }
      let(:batch_id) { batch.id }

      it { should respond_with(:success) }
      xit { should_not render_template("api/v1/batches/show") }
      it 'assigns the batch for the view' do
        expect(assigns(:batch)).to eq batch
      end
    end

    context "batch_id is not for a valid batch" do
      let(:batch_id) { -99 }
      let(:response_body) { JSON.parse(response.body) }

      it { should respond_with(:not_found) }
      it "responds with a batch not found error message" do
        expect(response_body).to eq({ "errors" => ["Batch not found"] })
      end
    end
  end

  describe "GET #index" do

    before(:each) do
      get :index, format: :json
    end

    it { should respond_with(:success) }
  end

end
