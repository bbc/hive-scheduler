DEVICE_DB = { url: Chamber.env['device_db']['url'], pem: Chamber.env['device_db']['client_pem'] }.with_indifferent_access

DeviceDBComms.configure do |config|
  config.url = DEVICE_DB[:url]
  config.pem_file = DEVICE_DB[:pem]
  config.ssl_verify_mode = OpenSSL::SSL::VERIFY_NONE
end

