Fabricator(:hive_queue) do
  name  { "queuename#{rand(100)}" }
end
