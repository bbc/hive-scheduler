require "spec_helper"

describe MonitoringController do
  describe "routing" do

    it "routes to #job_status" do
      get("/job_status").should route_to("monitoring#job_status")
    end

  end
end
