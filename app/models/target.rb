class Target < ActiveRecord::Base
  has_many :fields, as: :owner, dependent: :destroy
  has_many :scripts
end
