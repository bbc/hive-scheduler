Fabricator(:artifact) do
  asset do
    path=Rails.root.join("spec/fixtures/files/fox.txt")
    Rack::Test::UploadedFile.new(path, "text/plain", false)
  end
end
