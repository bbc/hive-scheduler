
Fabricator(:android_target, class_name: :target) do
  name  { "Android APK" }
  icon  { "android" }
  requires_build { true }
end
