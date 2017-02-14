require "spec_helper"

describe MonitoringController do

  describe '#job_status' do
    it 'should return success' do
      get :job_status
      expect(response.code).to eql("200")
    end

  end

end
