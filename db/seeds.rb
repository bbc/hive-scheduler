# Delete existing fields as they will be re-created below
Field.where(owner_type: "Target").delete_all

# Key the target types by database ID so we maintain existing relations
{
    1 => { name: "Android APK", icon: "android", requires_build: true, fields: {} },
    2 => { name: "iOS IPA", icon: "apple", requires_build: true, fields: {} },
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

# Dummy data used to provide a Job with results and screenshots
def add_test_results
  Script.find_or_create_by(id: 1, name: 'Test Script', template: '#!/bin/bash', target_id: 1)

  project = Project.first_or_create(
                #id: 1,
                name: 'Hive Test Project',
                script_id: 1,
                builder_name: 'manual_builder',
                repository: '.',
                execution_directory: '.',
                execution_variables: {},
                deleted_at: nil
            )

  HiveQueue.first_or_create(
      id: 1,
      name: 'nexus_5'
  )

  Batch.first_or_create(
      id: 1,
      name: 'Hive Test Batch',
      project_id: 1,
      version: '1.0.0',
  #    execution_variables: { "queues" => ['nexus_5'] }
  )

  JobGroup.first_or_create(
      id: 1,
      batch_id: 1,
      name: 'Hive Test: Device 1',
      hive_queue_id: 1
  )

  Job.first_or_create(
      id: 1,
      job_name: 'Hive Test',
      state: 'complete',
      queued_count: 0,
      running_count: 0,
      result: 'failed',
      job_group_id: 1,
      execution_variables: {},
      created_at: '2016-01-01 00:00:00',
      updated_at: '2016-01-01 00:00:00'
  )

  TestCase.first_or_create(
      id: 1,
      name: 'First test',
      project_id: project.id
  )

  TestCase.first_or_create(
      id: 2,
      name: 'Second test',
      project_id: project.id
  )

  TestResult.find_or_create_by(
      id: 1,
      status: 'passed',
      job_id: 1,
      test_case_id: 1
  )

  TestResult.find_or_create_by(
      id: 2,
      status: 'failed',
      job_id: 1,
      test_case_id: 2
  )

  Artifact.first_or_create(
      id: 1,
      job_id: 1,
      asset_file_name: 'test.jpg',
      asset_content_type: 'image/png'
  )

  Artifact.find_or_create_by(
      job_id: 1,
      asset_file_name: 'test.log',
      asset_content_type: 'text/x-log'
  )
end

# For dummy data uncomment these lines before running bin/rake db:seed
#add_test_results

#rspec_script = Script.create!(
#  name: 'Rspec tests',
#  target_id: 5,
#  template: <<TEMPLATE
#bundle install
#rspec
#if [ -e coverage ]
#then
#  tar -czf $HIVE_RESULTS/coverage.gz coverage
#fi
#TEMPLATE
#)
#
#cucumber_script = Script.create!(
#  name: 'Cucumber tests',
#  target_id: 5,
#  template: <<TEMPLATE
## This presumes that the Gemfile includes the line: gem 'res'
#bundle install
#bundle exec cucumber -f Res::Formatters::RubyCubumber -o $HIVE_RESULTS/out.res -f pretty `retry_args`
#TEMPLATE
#)
#
#project = Project.create!(
#  name: 'Hive Runner rspec',
#  repository: 'git@github.com:bbc/hive-runner.git',
#  builder_name: Builders::ManualBuilder.builder_name,
#  script: rspec_script
#)
