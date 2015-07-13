class AddNumberOfAutomaticRetriesToBatches < ActiveRecord::Migration
  def change
    add_column :batches, :number_of_automatic_retries, :integer
  end
end
