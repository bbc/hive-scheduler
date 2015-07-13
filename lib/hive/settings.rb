module Hive
  class Settings < Settingslogic
    source File.expand_path("../../../config/settings.yml", __FILE__)
    namespace Rails.env

  end
end
