require "spec_helper"

describe Api::StatusController do


  describe 'GET #show' do

    before(:each) do
      get :show
    end

    it { should respond_with(:success) }
  end
end
