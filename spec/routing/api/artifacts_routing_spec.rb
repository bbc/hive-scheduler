require "spec_helper"

describe Api::ArtifactsController do

  describe "routing" do

    it "routes POST /api/jobs/:job_id/artifacts to api/artifacts#create" do
      job_id = 99
      expect(post("/api/jobs/#{job_id}/artifacts")).to route_to("api/artifacts#create", job_id: job_id.to_s, format: :json)
    end
  end
end
