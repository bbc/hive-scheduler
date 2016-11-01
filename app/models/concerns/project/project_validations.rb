class Project < ActiveRecord::Base
  module ProjectValidations
    extend ActiveSupport::Concern

    included do

      validates :name, :script, :execution_directory, presence: true
      validates :name, uniqueness: true
      validates :builder_name, presence: true, "builders/validators/builder_name" => true
    end
  end
end
