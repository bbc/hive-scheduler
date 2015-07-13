class JobGroup < ActiveRecord::Base
  module JobGroupAssociations
    extend ActiveSupport::Concern

    included do
      belongs_to :batch
      has_many :jobs, dependent: :destroy
    end
  end
end
