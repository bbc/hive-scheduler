module Builders
  class TestRail < Builders::Base
    requires(test_rail_instance: :test_rail_instance, test_rail_plan_id: :integer)
    provides(:queues, :tests)
  end
end
