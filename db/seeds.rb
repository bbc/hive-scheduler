# Delete existing fields as they will be re-created below
Field.where(owner_type: "Target").delete_all

# Key the target types by database ID so we maintain existing relations
{
    1 => { name: "Android APK", icon: "android", requires_build: true, fields: {} },
    2 => { name: "iOS APK", icon: "apple", requires_build: true, fields: {} },
    3 => { name: "Mobile Browser", icon: "globe", requires_build: false, fields: { url: :string} },
    4 => { name: "TAL TV App", icon: "desktop", requires_build: false, fields: { application_url: :string, application_url_parameters: :string } },
    5 => { name: "Shell Script", icon: "file-text-o", requires_build: false, fields: {} }
}.each_pair do |target_id, target_attributes|
  fields=target_attributes.delete(:fields)

  target = Target.find_or_create_by(id: target_id)
  target.update!(target_attributes)
  target.fields.delete_all

  fields.each_pair do |field_name, field_value|
    target.fields << Field.create(name: field_name, field_type: field_value)
  end
end

ExecutionType.where(target_id: nil).update_all(target_id: 1)

{
    1 => { name: "Ruby versions", queues: %w('1.8.7', '1.9.3', '2.1.5') },

}.each_pair do |queue_id, attributes|
  queue = CuratedQueue.find_or_create_by(id: queue_id)
  queue.update!(attributes)
end

et = ExecutionType.create!(
  name: 'Dummy execution type',
  template: '# Do nothing',
  target_id: 5
)

project = Project.create!(
  name: 'Dummy project',
  repository: 'git@localhost:/tmp/dummy_repository',
  builder_name: Builders::ManualBuilder.builder_name,
  execution_type: et
)

batch = Batch.create!(
  name: 'Dummy batch',
  project: project,
  version: '1.0',
  build_file_name: '/tmp/dummy_build',
  execution_variables: { 'tests_per_job' => 10, 'tests_per_queue' => 10, 'tests' => [ 'one', 'two' ] },
)

jgb = Builders::ManualBuilder::JobGroupBuilder.new(batch: batch)
jgb.queue = 'dummy_queue'
jgb.perform
