namespace :hive do
  desc "Gather stats for the last month"
  task gather_stats: :environment do
    stats_directory = 'public/stats'

    queues = Rails.application.config.statistics[:queues]
    projects = Rails.application.config.statistics[:projects]

    FileUtils.mkdir_p stats_directory if ! Dir.exists? stats_directory
    date_label = DateTime.now.strftime('%y%m%d')
    files = {
      job_start: File.open("#{stats_directory}/job_start_time_#{date_label}.csv", 'w'),
      errors: File.open("#{stats_directory}/errors_#{date_label}.csv", 'w'),
      with_retries: File.open("#{stats_directory}/errors_with_retries-#{date_label}.csv", 'w')
    }

    job_start_keys = [
      "Date",
      "# jobs all queues",
      "1 min all queues",
      "2 min all queues",
      "20 min all queues",
    ]
    errors_keys = [
      "Date",
      "# jobs all queues",
      "# errors all queues",
      "% errors all queues",
    ]

    queues.each do |q|
      files["with_retries-#{q}"] = File.open("#{stats_directory}/errors_with_retries-#{q}-#{date_label}.csv", 'w')

      job_start_keys << "# jobs #{q}"
      job_start_keys << "1 min #{q}"
      job_start_keys << "2 min #{q}"
      job_start_keys << "20 min #{q}"
      errors_keys << "# jobs #{q}"
      errors_keys << "# errors #{q}"
      errors_keys << "% errors #{q}"
    end
    projects.each do |p|
      files["with_retries-#{p}"] = File.open("#{stats_directory}/errors_with_retries-#{p.gsub(' ', '_')}-#{date_label}.csv", 'w')
    end

    files[:job_start].puts job_start_keys.join ','
    files[:errors].puts errors_keys.join ','

    keys = {
      with_retries: [
        'Total jobs',
        'Cancelled',
        'Not cancelled',
        'Complete',
        'Passed',
        '% Passed',
        'Failed',
        '% Failed',
        'Errored',
        '% Errored',
        'Total jobs (after retries)',
        'Cancelled (after retries)',
        'Not cancelled (after retries)',
        'Complete (after retries)',
        'Passed (after retries)',
        '% Passed (after retries)',
        'Failed (after retries)',
        '% Failed (after retries)',
        'Errored (after retries)',
        '% Errored (after retries)',
        '0 retries',
        '1 retries',
        '2 retries',
        '3+ retries',
      ]
    }

    files[:with_retries].puts "Date," + keys[:with_retries].join(',')
    queues.each do |q|
      files["with_retries-#{q}"].puts "Date," + keys[:with_retries].join(',')
    end
    projects.each do |p|
      files["with_retries-#{p}"].puts "Date," + keys[:with_retries].join(',')
    end

    31.times do |i|
      day = (31 - i).days.ago

      date = day.strftime('%A %d %B %Y')
      puts date

      # List of original jobs (retry_count = 0)
      jbs = Job.joins(job_group: :hive_queue)
              .where("jobs.created_at < ? AND jobs.created_at >= ? AND jobs.retry_count = 0",
                        day.change(hour: 17, minute: 0, second: 0),
                        day.change(hour: 9, minute: 0, second: 0))

      files[:with_retries].puts [
          date,
          parse_errors_with_retries(data: jbs, keys: keys[:with_retries], queue: nil)
        ].flatten.join(',')
      last_len = 0
      queues.each do |q|
        print "\r - #{q}"
        print ' '*(last_len - q.length) if q.length < last_len
        last_len = q.length
        files["with_retries-#{q}"].puts [
          date,
          parse_errors_with_retries(data: jbs, keys: keys[:with_retries], queue: q)
        ].flatten.join(',')
      end
      projects.each do |p|
        print "\r - #{p}"
        print ' '*(last_len - p.length) if p.length < last_len
        last_len = p.length
        files["with_retries-#{p}"].puts [
          date,
          parse_errors_with_retries(data: jbs, keys: keys[:with_retries], project: p)
        ].flatten.join(',')
      end

      # List of jobs (including all retries)
      # TODO This is almost a duplicate of the query above. It should be
      #      possible to do just one query.
      jbs = Job.joins(job_group: :hive_queue)
              .where("jobs.created_at < ? AND jobs.created_at >= ?",
                        day.change(hour: 17, minute: 0, second: 0),
                        day.change(hour: 9, minute: 0, second: 0))

      job_start_stats = [
          date,
          parse_job_start(jbs, nil)
      ]
      errors_stats = [
          date,
          parse_job_start(jbs, nil)
      ]
      queues.each do |q|
        job_start_stats << parse_job_start(jbs, q)
        errors_stats << parse_error_count(jbs, q)
      end
      
      files[:job_start].puts job_start_stats.flatten.join ','
      files[:errors].puts errors_stats.flatten.join ','

      print "\r - [DONE]"
      print ' '*(last_len - 6) if 6 < last_len
      puts
    end
    files[:job_start].close
    files[:errors].close
    files[:with_retries].close
    queues.each do |q|
      files["with_retries-#{q}"].close
    end
    projects.each do |p|
      files["with_retries-#{p}"].close
    end
  end

  def parse_errors_with_retries options
    if options[:queue]
      data = options[:data].select { |j| j.job_group.hive_queue.name == options[:queue] }
    elsif options[:project]
      data = options[:data].select { |j| j.project.name == options[:project] }
    else
      data = options[:data]
    end
    data_out = {}

    not_cancelled = data.select { |d| d.status != 'cancelled' }
    data_out['Total jobs'] = data.count
    data_out['Cancelled'] = data.count - not_cancelled.count
    data_out['Not cancelled'] = not_cancelled.count
    data_out['Complete'] = not_cancelled.select{|j| j.state == 'complete'}.count
    data_out['Passed'] = not_cancelled.select{|j| j.status == 'passed'}.count
    data_out['% Passed'] = 100.0 * data_out['Passed'] / data_out ['Not cancelled']
    data_out['Failed'] = not_cancelled.select{|j| j.status == 'failed'}.count
    data_out['% Failed'] = 100.0 * data_out['Failed'] / data_out ['Not cancelled']
    data_out['Errored'] = not_cancelled.select{|j| j.status == 'errored'}.count
    data_out['% Errored'] = 100.0 * data_out['Errored'] / data_out ['Not cancelled']
    data_out['0 retries'] = 0
    data_out['1 retries'] = 0
    data_out['2 retries'] = 0
    data_out['3+ retries'] = 0

    latest = data.map { |j|
      while j.replacement
        j = j.replacement
      end
      if j.retry_count < 3
        data_out["#{j.retry_count} retries"] += 1
      else
        data_out["3+ retries"] += 1
      end
      j
    }
    latest_not_cancelled = latest.select { |d| d.status != 'cancelled' }
    data_out['Total jobs (after retries)'] = latest.count
    data_out['Cancelled (after retries)'] = latest.count - latest_not_cancelled.count
    data_out['Not cancelled (after retries)'] = latest_not_cancelled.count
    data_out['Complete (after retries)'] = latest_not_cancelled.select{|j| j.state == 'complete'}.count
    data_out['Passed (after retries)'] = latest_not_cancelled.select{|j| j.status == 'passed'}.count
    data_out['Failed (after retries)'] = latest_not_cancelled.select{|j| j.status == 'failed'}.count
    data_out['Errored (after retries)'] = latest_not_cancelled.select{|j| j.status == 'errored'}.count

    options[:keys].map{ |k| data_out[k] }
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
