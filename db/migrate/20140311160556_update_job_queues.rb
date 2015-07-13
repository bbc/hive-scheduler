class UpdateJobQueues < ActiveRecord::Migration
  def change
    Job.all.each do |job|
      if queue_matcher = job.job_name.match(/\(.+\)/)
        job.queue_name = queue_matcher[0].sub(/^\(/, '').sub(/\)$/, '')
        job.job_name = job.job_name.sub(queue_matcher[0], '').strip
        job.save
      end
    end
  end
end
