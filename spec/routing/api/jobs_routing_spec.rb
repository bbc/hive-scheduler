require "spec_helper"

describe Api::JobsController do

  describe "routing" do

    describe "show route" do
      it "routes GET /api/jobs/99 to api/jobs#show" do
        job_id="99"
        expect(get("/api/jobs/#{job_id}")).to route_to("api/jobs#show", id: job_id, format: :json)
      end
    end

    describe "reservation route" do

      it "routes PATCH /api/queues/:queue_names/jobs/reserve to api/jobs#reserve" do
        queue_names = "nexus-5,nexus-4"
        expect(patch("/api/queues/#{queue_names}/jobs/reserve")).to route_to("api/jobs#reserve", queue_names: queue_names, format: :json)
      end

      it "copes with dots in the queue names" do
        queue_names = "nexus-5,nexus.4"
        expect(patch("/api/queues/#{queue_names}/jobs/reserve.json")).to route_to("api/jobs#reserve", queue_names: queue_names, format: "json")
      end

    end

    it "routes PATCH /api/jobs/:id/start to api/jobs#start" do
      job_id = 99
      expect(patch("/api/jobs/#{job_id}/start")).to route_to("api/jobs#start", job_id: job_id.to_s, format: :json)
    end

    it "routes PATCH /api/jobs/:id/update_results to api/jobs#update_results" do
      job_id = 99
      expect(patch("/api/jobs/#{job_id}/update_results")).to route_to("api/jobs#update_results", job_id: job_id.to_s, format: :json)
    end

    it "routes PATCH /api/jobs/:id/error to api/jobs#error" do
      job_id = 99
      expect(patch("/api/jobs/#{job_id}/error")).to route_to("api/jobs#error", job_id: job_id.to_s, format: :json)
    end

    it "routes PATCH /api/jobs/:id/end to api/jobs#end" do
      job_id = 99
      expect(patch("/api/jobs/#{job_id}/end")).to route_to("api/jobs#end", job_id: job_id.to_s, format: :json)
    end
  end
end
