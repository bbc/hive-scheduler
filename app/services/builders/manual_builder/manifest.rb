module Builders
  class ManualBuilder < Builders::Base
    module Manifest
      BUILDER_NAME  = "manual_builder"
      FRIENDLY_NAME = "Manual"
      BATCH_BUILDER = Builders::ManualBuilder::BatchBuilder
    end
  end
end
