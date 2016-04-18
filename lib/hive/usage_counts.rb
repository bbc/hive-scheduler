module Hive
  class UsageCounts
    
    
    
    
    def self.count_per_month( args = {} )
      
      iterations = args[:months].to_i || 24
      interval = 1.month
      
      (0 .. iterations).to_a.reverse.collect do |i|
        time = Time.now - i * interval
        start_time = time.beginning_of_month
        end_time =  time.end_of_month
        count = yield( start_time, end_time)
        if args[:scale_partial] && i == 0
          ratio = (time - time.beginning_of_month) / (time.end_of_month - time.beginning_of_month)
          count = count / ratio
        end
        
        {date: start_time.strftime("%b %y"), count: count}
      end
      
    end
    
    def self.batch_counts( args = {} )
      Hive::UsageCounts::count_per_month( args.merge({ :scale_partial => true }) ) do |start_time, end_time|
        Batch.all.where( 'created_at > ? and created_at <= ?',
                           start_time, end_time).count
      end
    end
    
    def self.project_counts( args = {} )
      Hive::UsageCounts::count_per_month( args ) do |start_time, end_time|
        Batch.where( 'created_at > ? and created_at <= ?', start_time, end_time).pluck(:project_id).uniq.count
      end
    end
    
    def self.device_hours( args = {} )

      iterations = args[:days].to_i || 14
      interval = 1.day
      
      (0 .. iterations).to_a.reverse.collect do |i|
        time = Time.now - i * interval
        start_time = time.beginning_of_day
        end_time =  time.end_of_day
        
        hours = Job.where( 'created_at > ? and created_at <= ?', start_time, end_time ).collect { |j| j.end_time.to_i > 0 ? j.end_time.to_f -  j.start_time.to_f : 0.0 }.sum / 60 / 60
        
        if args[:scale_partial] && i == 0
          ratio = (time - time.beginning_of_day) / (time.end_of_day - time.beginning_of_day)
          count = count / ratio
        end
        
        {date: start_time.strftime("%a"), count: hours}

      end
    end
    
  end
     
end
