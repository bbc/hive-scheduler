class AddDefaultValueToFields < ActiveRecord::Migration
  def change
    add_column :fields, :default_value, :string
  end
end
