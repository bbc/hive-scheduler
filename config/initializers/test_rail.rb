# Chamber does not pick up environment variables if they are not explicitly
# given in the settings.yml file. This allows arbitrary test rail accounts
# to be specified as:
#
#    TEST_RAIL_ACCOUNT_ONE_USER=username
#    TEST_RAIL_ACCOUNT_ONE_PASSWORD=password
#
# These will be available as:
#
#   Chamber.env.account_one.user or Chamber.env['account_one'].user
#   Chamber.env.account_one.password or Chamber.env['account_one'].password

m = /^TEST_RAIL_(.*)_USER$/
ENV.keys.select { |x| m.match(x) }.map{ |x| m.match(x)[1] }.each do |a|
  Chamber.env.test_rail = {
    a.downcase => {
      user: ENV["TEST_RAIL_#{a}_USER"],
      password: ENV["TEST_RAIL_#{a}_PASSWORD"]
    }
  }
end
