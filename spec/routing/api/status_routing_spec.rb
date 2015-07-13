require "spec_helper"

describe Api::StatusController do

  describe "routing" do

    it "routes GET /status to api/status#show" do
      expect(get("/status")).to route_to("api/status#show")
    end
  end
end
