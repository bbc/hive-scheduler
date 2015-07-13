
Fabricator(:field) do
  name        { "field_#{Fabricate.sequence(:field)}" }
  field_type  { 'string' }
end


Fabricator(:cucumber_tags_field, from: :field) do
  name        { "cucumber_tags" }
  field_type  { 'string' }
end

