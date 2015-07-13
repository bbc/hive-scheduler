Fabricator(:test_rail_plan, class_name: "TestRail::Plan") do

  id          { sequence(:plan_id) }
  name        { |plan| "Test Rail Plan #{plan[:id]}" }
  description { Forgery(:lorem_ipsum).words(8) }

  after_create do |plan|
    TestRail::API.any_instance.stub(:get_plan).with(plan_id: plan.id).and_return(plan)
    TestRail::Plan.stub(:find_by_id).with(plan[:id]).and_return(plan)
  end
end


Fabricator(:test_rail_plan_with_tests, from: :test_rail_plan) do
  runs(count: 2) {  Fabricate(:test_rail_run_with_two_tests) }
end
