require 'mind_meld/device'

Rails.application.config.hive_mind = nil

if Chamber.env['hive_mind'] 

  HIVE_MIND = { url:         Chamber.env['hive_mind']['url'],
                cert:         Chamber.env['hive_mind']['cert'],
                cacert:     Chamber.env['hive_mind']['cacert'],
                verify_mode: Chamber.env['hive_mind']['verify_mode'].to_i,
              }.with_indifferent_access

  Rails.application.config.hive_mind_url = HIVE_MIND['url']
  Rails.application.config.hive_mind_cert = HIVE_MIND['cert']
  Rails.application.config.hive_mind_cacert = HIVE_MIND['cacert']
  Rails.application.config.hive_mind_verify_mode = HIVE_MIND['verify_mode']

end