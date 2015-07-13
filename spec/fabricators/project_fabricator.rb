Fabricator(:project) do
  name { "Project #{Fabricate.sequence(:project)}" }
  execution_type { Fabricate(:execution_type) }
  repository { 'repo' }
  execution_directory { '.' }
  builder_name { Builders::Registry.registered_builders.first.builder_name }
end

Fabricator(:test_rail_project, from: :project) do
  builder_name { "test_rail" }
  builder_options do
    {
        "test_rail_plan_id"  => Fabricate(:test_rail_plan_with_tests).id,
        "test_rail_instance" => Chamber.env.test_rail.keys.first
    }
  end
end

Fabricator(:manual_project, from: :project) do
  name { "Manual Project #{Fabricate.sequence(:manual_project)}" }
  execution_type { Fabricate(:cucumber_execution_type) }
  builder_name { "manual_builder" }
  builder_options do
    { "cucumber_tags" => "some tag", "queues" => ["q1", "q2"] }
  end
end
