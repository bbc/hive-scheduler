class Job < ActiveRecord::Base
  module JobDevice
    extend ActiveSupport::Concern

    def device_type
      if device_details['brand']
        device_details['brand'] + " " + device_details['model']  
      end 
    end

    def device_name
      device_details['name']
    end
    
    def device_details
      if device_id
        begin
          Rails.cache.fetch("device_#{device_id}", expires_in: 5.minutes) do
            
            connection = MindMeld::Device.new(
              url: Rails.application.config.hive_mind_url,
              pem: Rails.application.config.hive_mind_cert,
              ca_file:   Rails.application.config.hive_mind_cacert,
              verify_mode:   Rails.application.config.hive_mind_verify_mode,
              device: { id: device_id }
            )

            connection.device_details
          end
        rescue => e
          Rails.logger.info "Failed to retrieve device details: #{e.backtrace}"
          {}
        end
      else
        {}
      end
    end
    
  end
end
