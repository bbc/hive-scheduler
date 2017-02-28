require "spec_helper"

describe MonitoringController do
  describe "routing" do

    it "routes to #job_status" do
      get("/job_status").should route_to("monitoring#job_status")
    end

    it "routes to #job_status_project_graph" do
      get("/job_status/project/1").should route_to("monitoring#job_status_project_graph", project_id: "1")
    end

  end
end
