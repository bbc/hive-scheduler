Fabricator(:job, aliases: [:queued_job] ) do
  job_name            { "Fabricated Job #{Fabricate.sequence(:fabricated_job)}" }
  queued_count        { 9 }
  job_group
  execution_variables { { "tests" => ['test one', 'test two', 'test three'] } }
end

Fabricator(:reserved_job, from: :job) do
  state               { "reserved" }
  reservation_details { {hive_id: 99, hive_pid: 1024} }
  reserved_at         { Time.now }
end

Fabricator(:running_job, from: :job) do
  state               { "running" }
end

Fabricator(:completed_job, from: :job) do
  state               { "complete" }
end

Fabricator(:errored_job, from: :job) do
  state               { "errored" }
end

Fabricator(:analyzing_job, from: :job) do
  state               { "analyzing" }
end

Fabricator(:passed_job, from: :job) do
  state               { "complete" }
  result              { "passed"   }
end

Fabricator(:failed_job, from: :job) do
  state               { "complete" }
  result              { "failed"   }
end
