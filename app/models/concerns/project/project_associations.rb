class Project < ActiveRecord::Base
  module ProjectAssociations
    extend ActiveSupport::Concern

    included do
      belongs_to :execution_type
      has_many   :batches
      has_many   :assets
    end
  end
end
