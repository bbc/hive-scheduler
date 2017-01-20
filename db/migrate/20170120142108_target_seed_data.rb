class TargetSeedData < ActiveRecord::Migration
  def up
    # Do this all once in case this is being run on a server that hasn't
    # previously been set up with the db/seed.rb file
    Field.where(owner_type: "Target").delete_all
   
    # Key the target types by database ID so we maintain existing relations
    {
      1 => { name: "Android APK", icon: "android", requires_build: true, fields: { resign: :boolean } },
      2 => { name: "iOS IPA", icon: "apple", requires_build: true, fields: { resign: :boolean } },
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
  end

  def down
    # Revert to the old default seed data
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
  end
end
