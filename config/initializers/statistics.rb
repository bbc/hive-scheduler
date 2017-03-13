require 'mind_meld/device'

Rails.application.config.statistics = {
  queues: [],
  projects: []
}

if Chamber.env.statistics
  [:queues, :projects].each do |type|
    if Chamber.env.statistics[type]
      # Chamber doesn't currently allow for an array to be set by environment
      # variables so use a comma separated list
      Rails.application.config.statistics[type] = Chamber.env.statistics[type].split ','
    else
      Rails.application.config.statistics[type] = []
    end
  end
end
