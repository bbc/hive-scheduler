Fabricator(:test_rail_test, class_name: "TestRail::Test") do

  id { sequence(:test_id) }
  title { |test| "Test #{test[:id]}" }
end
