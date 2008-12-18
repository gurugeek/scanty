configure do
	require 'ostruct'
	Blog = OpenStruct.new(
		:title => 'a name for your blog',
		:author => 'Joel Tulloch',
		:url_base => 'http://localhost:4567/',
		:database_name => 'change_db_name',
		:url_base_database => nil,
		:admin_password => 'changethis',
		:admin_cookie_key => 'admin_cookie_key',
		:admin_cookie_value => '54l976913ace58',
		:disqus_shortname => nil
	)
end