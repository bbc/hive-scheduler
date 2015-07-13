module BuilderHelpers

  def valid_builder_klass
    klass = Class.new(Builders::Base)
    manifest = Module.new
    manifest.const_set(:BUILDER_NAME, "valid_builder")
    manifest.const_set(:BATCH_BUILDER, :batch_builder)
    manifest.const_set(:FRIENDLY_NAME, "Valid Builder")
    klass.const_set(:Manifest, manifest)
    klass
  end
end
