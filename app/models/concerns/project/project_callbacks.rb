class Project < ActiveRecord::Base
  module ProjectCallbacks
    extend ActiveSupport::Concern

    included do
      after_initialize do |project|
        project.builder_options = {} unless project.builder_options.present?
      end
    end
  end
end
