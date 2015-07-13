require "spec_helper"

describe Api::BatchesController do

  describe "routing" do

    it "routes GET /api/batches/:id/show to api/batches#show" do
      batch_id = 99
      expect(get("/api/batches/#{batch_id}")).to route_to("api/batches#show", id: batch_id.to_s, format: :json)
    end

    it "routes GET /api/batches to api/batches#index" do

      expect(get("/api/batches")).to route_to("api/batches#index", format: :json)
    end
  end
end
