class ExecutionType < ActiveRecord::Base
  include ExecutionTypeValidations

  belongs_to :target
  has_many   :projects
  has_many   :target_fields, class_name: "Field", through: :target
  has_many   :execution_variables, as: :owner, class_name: "Field", dependent: :destroy

  validates :target, presence: true

  accepts_nested_attributes_for :execution_variables, reject_if: :all_blank, allow_destroy: true

  delegate :requires_build?, to: :target
end
