class Project < ActiveRecord::Base
  module ProjectAssociations
    extend ActiveSupport::Concern

    included do
      belongs_to :script
      has_many   :batches
    end
  end
end
