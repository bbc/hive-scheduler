Fabricator(:test_rail_run, class_name: "TestRail::Run") do
  initialize_with { TestRail::Run.new({}) }

  id { sequence(:run_id) }
  name { |run| "Test Run #{run[:id]}" }
  description { Forgery(:lorem_ipsum).words(8) }
  config { "device_#{sequence(:run_id)}" }
end

Fabricator(:test_rail_run_with_tests, from: :test_rail_run) do

  after_create do |run|
    run.stub(tests: Fabricate.times(Forgery::Basic.number, :test_rail_test))
  end
end

Fabricator(:test_rail_run_with_two_tests, from: :test_rail_run) do

  after_create do |run|
    run.stub(tests: Fabricate.times(2, :test_rail_test))
  end
end
