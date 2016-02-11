class ModifyJobGroupTable < ActiveRecord::Migration
  def up
    add_reference :job_groups, :hive_queue, index: true
    
    JobGroup.find_each do |jg|
      queue = HiveQueue.find_or_create_by( name: jg.queue_name )
      jg.update( hive_queue_id: queue.id )
    end

    remove_column :job_groups, :queue_name, :string
  end
end
