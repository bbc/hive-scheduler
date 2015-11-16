class Job < ActiveRecord::Base
  module JobDevice
    extend ActiveSupport::Concern

    def device_type
      device_details['formal_name'] 
    end

    def device_name
      device_details['name']
    end
    
    def device_details
      if device_id
        begin
          Rails.cache.fetch("device_#{device_id}", expires_in: 5.minutes) do
            devicedb = DeviceDBComms::Device.new
            devicedb.find(device_id)
          end
        rescue => e
          Rails.logger.info "*"*50
          Rails.logger.info "Failed to connect to DeviceDB: #{e.backtrace}"
          Rails.logger.info "*"*50
          Hash.new('')
        end
      else
        Hash.new('')
      end
    end
    
  end
end
