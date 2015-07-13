require "spec_helper"

describe Admin::AdminController do

  controller(Admin::AdminController) do

    def index
      render text: "OK"
    end
  end
end
