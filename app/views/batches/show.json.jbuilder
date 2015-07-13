json.array! @jobs.values.flatten do |job|
  json.(job, :id, :status, :running_count, :passed_count, :failed_count, :errored_count)
  json.queued_count job.queued_count || "?"
end
