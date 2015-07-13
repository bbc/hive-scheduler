module Builders
  class TestRail < Builders::Base

    module Manifest
      BUILDER_NAME    = "test_rail"
      FRIENDLY_NAME   = "Test Rail Plan"
      BATCH_BUILDER   = Builders::TestRail::BatchBuilder
    end
  end
end
