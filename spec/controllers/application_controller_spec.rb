require "spec_helper"

describe ApplicationController do

  controller do

    def index
      render text: "OK"
    end
  end

  describe "access control" do

    before(:each) do
      get :index
    end

    it "does not redirect to user login" do
      expect(response.code).to eql("200")
    end
  end
end
