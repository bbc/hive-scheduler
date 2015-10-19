if ActiveRecord::Base.connection.table_exists? 'fields' 
	 Builders::Registry.register(Builders::TestRail) if Chamber.env.test_rail?
	 Builders::Registry.register(Builders::ManualBuilder)
end
