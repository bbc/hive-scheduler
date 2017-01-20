# Dummy data used to provide a Job with results and screenshots
def add_test_results
  android_target = Target.where(name: 'Android APK')
  Script.find_or_create_by(id: 1, name: 'Test Script', template: '#!/bin/bash', target: android_target)

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

# script_target = Target.where(name: 'Shell Script').first
#rspec_script = Script.create!(
#  name: 'Rspec tests',
#  target: script_target,
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
#  target: script_target,
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
