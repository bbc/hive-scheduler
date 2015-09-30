class TestResult < ActiveRecord::Base
  belongs_to :test_case
  belongs_to :job
end
