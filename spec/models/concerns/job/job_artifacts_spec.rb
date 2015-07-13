require 'spec_helper'

describe Job::JobArtifacts do

  describe "instance methods" do

    before(:each) do
      Job.any_instance.stub(:publish_to_queue)
    end

    let(:job) { Fabricate(:job) }

    let(:cucumber_file) { Rails.root.join("spec/fixtures/files/pretty.out") }
    let(:cucumber_asset) do
      Rack::Test::UploadedFile.new(cucumber_file, "text/plain", false)
    end
    let!(:cucumber_artifact) { Fabricate(:artifact, asset: cucumber_asset, job: job) }

    let(:worker_file) { Rails.root.join("spec/fixtures/files/worker_thread.log") }
    let(:worker_asset) do
      Rack::Test::UploadedFile.new(worker_file, "text/plain", false)
    end
    let!(:worker_artifact) { Fabricate(:artifact, asset: worker_asset, job: job) }


    let(:screenshot_1_file) { Rails.root.join("spec/fixtures/files/screenshot_1.png") }
    let(:screenshot_1_asset) do
      Rack::Test::UploadedFile.new(screenshot_1_file, "image/png", false)
    end
    let!(:screenshot_1_artifact) { Fabricate(:artifact, asset: screenshot_1_asset, job: job) }

    let(:screenshot_2_file) { Rails.root.join("spec/fixtures/files/screenshot_2.png") }
    let(:screenshot_2_asset) do
      Rack::Test::UploadedFile.new(screenshot_2_file, "image/png", false)
    end
    let!(:screenshot_2_artifact) { Fabricate(:artifact, asset: screenshot_2_asset, job: job) }

    describe "#stdout" do

      it "outputs the attatchment named pretty.out" do
        expect(job.stdout).to eq File.read(cucumber_file)
      end
    end

    describe "#logs" do

      it "outputs a hash of file names/urls for each logfile" do
        expect(job.log_files['worker_thread.log']).to eq( worker_artifact.asset.expiring_url(10*60) )
      end
    end

    describe "#images" do

      let(:expected_screenshot_hash) do
        { screenshot_1_artifact.asset_file_name => screenshot_1_artifact.asset.expiring_url(10*60),
          screenshot_2_artifact.asset_file_name => screenshot_2_artifact.asset.expiring_url(10*60) }
      end

      it "outputs a hash of filenames/download urls for the screenshots" do
        expect(job.images).to eq expected_screenshot_hash
      end
    end
  end
end
