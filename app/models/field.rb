class Field < ActiveRecord::Base
  validates :name, :field_type, presence: true
  belongs_to :owner, polymorphic: true
end
