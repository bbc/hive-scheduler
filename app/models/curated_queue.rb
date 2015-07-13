class CuratedQueue < ActiveRecord::Base

  serialize :queues, JSON
end
