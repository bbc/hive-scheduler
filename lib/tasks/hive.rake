namespace :hive do
  desc "Gather stats for the last month"
  task gather_stats: :environment do
    stats_directory = 'public/stats'

    Dir.mkdir stats_directory if ! Dir.exists? stats_directory
    date_label = DateTime.now.strftime('%y%m%d')
    files = {
      job_start: File.open("#{stats_directory}/job_start_time_#{date_label}.csv", 'w'),
      errors: File.open("#{stats_directory}/errors_#{date_label}.csv", 'w')
    }

    files[:job_start].puts [
      "Date",
      "# jobs all queues",
      "1 min all queues",
      "2 min all queues",
      "20 min all queues",
      "# jobs nexus_range",
      "1 min nexus_range",
      "2 min nexus_range",
      "20 min nexus_range",
      "# jobs amazon-firetv_stick",
      "1 min amazon-firetv_stick",
      "2 min amazon-firetv_stick",
      "20 min amazon-firetv_stick",
    ].join ','

    files[:errors].puts [
      "Date",
      "# jobs all queues",
      "# errors all queues",
      "% errors all queues",
      "# jobs nexus_range",
      "# errors nexus_range",
      "% errors nexus_range",
      "# jobs amazon-firetv_stick",
      "# errors amazon-firetv_stick",
      "% errors amazon-firetv_stick",
    ].join ','

    31.times do |i|
      day = (31 - i).days.ago
      jbs = Job.joins(job_group: :hive_queue)
              .where("jobs.created_at < ? AND jobs.created_at >= ?",
                        day.change(hour: 17, minute: 0, second: 0),
                        day.change(hour: 9, minute: 0, second: 0))

      not_cancelled = jbs.select { |d| d.status != 'cancelled' }
      qd = not_cancelled.select{ |d| d.start_time == nil }
      one_min = not_cancelled.select{ |d| d.start_time and d.start_time - d.created_at < 1.minute }
      two_min = not_cancelled.select{ |d| d.start_time and d.start_time - d.created_at < 2.minute }
      twenty_mins = not_cancelled.select{ |d| d.start_time and d.start_time - d.created_at < 20.minutes }
      results = {}
      [ 'passed', 'failed', 'errored' ].each do |r|
        results[r] = not_cancelled.select{ |d| d.status == r }
      end
      date = day.strftime('%A %d %B %Y')
      puts date

      files[:job_start].puts [
          date,
          parse_job_start(jbs, nil),
          parse_job_start(jbs, 'nexus_range'),
          parse_job_start(jbs, 'amazon-firetv_stick'),
        ].flatten.join ','

      files[:errors].puts [
        date,
        parse_error_count(jbs, nil),
        parse_error_count(jbs, 'nexus_range'),
        parse_error_count(jbs, 'amazon-firetv_stick'),
      ].join ','
    end
    files[:job_start].close
    files[:errors].close
  end

  def parse_job_start data_in, queue
    if queue
      data = data_in.select { |j| j.job_group.hive_queue.name == queue }
    else
      data = data_in
    end

    not_cancelled = data.select { |d| d.status != 'cancelled' }
    qd = not_cancelled.select{ |d| d.start_time == nil }
    one_min = not_cancelled.select{ |d| d.start_time and d.start_time - d.created_at < 1.minute }
    two_min = not_cancelled.select{ |d| d.start_time and d.start_time - d.created_at < 2.minute }
    twenty_mins = not_cancelled.select{ |d| d.start_time and d.start_time - d.created_at < 20.minutes }

    [
      not_cancelled.count,
      100.0 * one_min.count / not_cancelled.count,
      100.0 * two_min.count / not_cancelled.count,
      100.0 * twenty_mins.count / not_cancelled.count,
    ]

  end

  def parse_error_count data_in, queue
    if queue
      data = data_in.select { |j| j.job_group.hive_queue.name == queue }
    else
      data = data_in
    end

    not_cancelled = data.select { |d| d.status != 'cancelled' }
    results = {}
    [ 'passed', 'failed', 'errored' ].each do |r|
      results[r] = not_cancelled.select{ |d| d.status == r }
    end

    [
      not_cancelled.count,
      results['errored'].count,
      100.0 * results['errored'].count / not_cancelled.count
    ]
  end

end
