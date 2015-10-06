class Project < ActiveRecord::Base
  module ProjectAssociations
    extend ActiveSupport::Concern

    included do
      belongs_to :script
      has_many   :batches
      has_many   :assets
      has_many   :test_cases
    end
  end
end
