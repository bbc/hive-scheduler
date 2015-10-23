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

# For dummy data uncomment these lines before running bin/rake db:seed
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
