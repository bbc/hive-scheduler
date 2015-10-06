if ActiveRecord::Base.connection.table_exists? 'fields' 
	 Builders::Registry.register(Builders::TestRail)
	 Builders::Registry.register(Builders::ManualBuilder)
end
