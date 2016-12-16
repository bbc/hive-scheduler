require "spec_helper"

describe Api::BatchesController do

  describe "POST #create" do

    context 'no build' do
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

    context "mobile tests" do
      let(:target) { Target.create! requires_build: true }
      let(:script) { Script.create! target: target, name: 'Test script', template: 'Test template' }
      let(:project) { Project.create! script: script, name: 'Test project', builder_name: Builders::ManualBuilder.builder_name, repository: '' }
      let(:build) { [ Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/android_build.apk"), 'application/vnd.android.package-archive', false) ] }
      let(:build2) { [ Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/android_build_2.apk"), 'application/vnd.android.package-archive', false) ] }

      it 'creates a new asset for the build' do
        expect{ post :create, { format: :json, version: '1', build: build, project_id: project.id} }.to change(Asset, :count).by 1
      end

      it 'creates a single asset for two batchs of the same project and version with the same file' do
        post :create, { format: :json, version: '1', build: build, project_id: project.id }
        expect{ post :create, { format: :json, version: '1', build: build, project_id: project.id} }.to change(Asset, :count).by 0
      end

      it 'creates a new asset for a second batch of the same project and version with a different file name' do
        post :create, { format: :json, version: '1', build: build, project_id: project.id }
        expect{ post :create, { format: :json, version: '1', build: build2, project_id: project.id} }.to change(Asset, :count).by 1
      end

      it 'links a new asset to the batch' do
        expect{ post :create, { format: :json, version: '1', build: build, project_id: project.id} }.to change(BatchAsset, :count).by 1
        expect(BatchAsset.last.batch).to eq Batch.last
        expect(BatchAsset.last.asset).to eq Asset.last
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
