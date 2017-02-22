class SetResignTrue < ActiveRecord::Migration
  def change
    reversible do |change|
      change.up do
        Field.where(owner_type: 'Target', name: 'resign').update_all(default_value: 1)
      end

      change.down do
        Field.where(owner_type: 'Target', name: 'resign').update_all(default_value: nil)
      end
    end
  end
end
