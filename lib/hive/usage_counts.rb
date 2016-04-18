module Hive
  class UsageCounts
    
    def self.jobs_count( args )
      
      iterations = args[:months].to_i || 24
      interval = 1.month
      
      (0 .. iterations).to_a.reverse.collect do |i|
        time = Time.now - i * interval
        start_time = time.beginning_of_month
        end_time =  time.end_of_month
        count = Batch.all.where( 'created_at > ? and created_at <= ?',
                           start_time, end_time).count
        if i == 0
          ratio = (time - time.beginning_of_month) / (time.end_of_month - time.beginning_of_month)
          count = count / ratio
        end
        
        {date: start_time.strftime("%b %y"), count: count}
      end
      
    end
    
  end
     
end
