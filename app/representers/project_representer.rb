module ProjectRepresenter
  include Roar::JSON
  
  property :id  
  property :name  
  property :repository
  property :latest_batch, extend: BatchJobGroupRepresenter
end
