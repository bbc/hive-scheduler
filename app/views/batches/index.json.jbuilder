json.array! @batches do |batch|
  json.(batch, :id, :state, :jobs_queued, :jobs_running, :jobs_passed, :jobs_failed, :jobs_errored)
end
