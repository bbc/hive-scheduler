class TestCase < ActiveRecord::Base
  belongs_to :project
  
  def self.find_or_create_by_test_name( name, project_id )
    TestCase.where(name: name, project_id: project_id).first_or_create do |test_case|
      test_case.name = name
      test_case.project_id = project_id
    end
  end
  
end
