class Auxiliary < ActiveRecord::Migration
	def self.up
		adapter = ActiveRecord::Base.connection.instance_values["config"][:adapter]
		if adapter == "sqlite3"
			execute "delete from schema_migrations;"
		else
			execute "TRUNCATE schema_migrations;"
		end
		execute "INSERT INTO schema_migrations VALUES ('20151002073630');"
	end
	def self.down
		raise ActiveRecord::IrreversibleMigration
	end
end
