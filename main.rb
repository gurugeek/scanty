require 'rubygems'
require 'sinatra'

configure do
	require 'ostruct'
	Blog = OpenStruct.new(
		:title => 'scanty on the couch',
		:author => 'Joel Tulloch',
		:url_base => 'http://localhost:4567/',
		:database_name => 'change_this',
		:url_base_database => nil,
		:admin_password => 'changethis',
		:admin_cookie_key => 'admin_cookie_key',
		:admin_cookie_value => '54l976913ace58',
		:disqus_shortname => nil
	)
end

error do
	e = request.env['sinatra.error']
	puts e.to_s
	puts e.backtrace.join("\n")
	"Application error"
end

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/lib')
require 'post'

helpers do
	def admin?
		request.cookies[Blog.admin_cookie_key] == Blog.admin_cookie_value
	end

	def auth
		stop [ 401, 'Not authorized' ] unless admin?
	end
	
	def parse_tags tags
	  tags.split(" ")
	end 
end

layout 'layout'

### Public

get '/' do
  posts = Post.by_created_at :count=>10
	erb :index, :locals => { :posts => posts }, :layout => false
end

get '/past/:year/:month/:day/:slug/' do
  post = Post.by_slug(:key=>params[:slug], :count=>1).first
	stop [ 404, "Page not found" ] unless post
	@title = post.title
	erb :post, :locals => { :post => post }
end

get '/past/:year/:month/:day/:slug' do
	redirect "/past/#{params[:year]}/#{params[:month]}/#{params[:day]}/#{params[:slug]}/", 301
end

get '/past' do
  posts = Post.by_created_at
	@title = "Archive"
	erb :archive, :locals => { :posts => posts }
end

get '/past/tags/:tag' do
  tag = params[:tag]
	posts = Post.by_tags(:key=>tag).sort_by do |post|
    post.created_at
	end # TODO:: Limit results to 30
	@title = "Posts tagged #{tag}"
	erb :tagged, :locals => { :posts => posts, :tag => tag }
end

get '/feed' do
	@posts = Post.by_created_at :count=>10
	content_type 'application/atom+xml', :charset => 'utf-8'
	builder :feed
end

get '/rss' do
	redirect '/feed', 301
end

### Admin

get '/auth' do
	erb :auth
end

post '/auth' do
	set_cookie(Blog.admin_cookie_key, Blog.admin_cookie_value) if params[:password] == Blog.admin_password
	redirect '/'
end

get '/posts/new' do
	auth
	erb :edit, :locals => { :post => Post.new, :url => '/posts' }
end

post '/posts' do
	auth
	post = Post.new :title => params[:title], :tags => parse_tags(params[:tags]), :body => params[:body], :slug => Post.make_slug(params[:title])
	post.save
	redirect post.url
end

get '/past/:year/:month/:day/:slug/edit' do
	auth
	post = Post.by_slug(:key=>params[:slug], :count=>1).first
	stop [ 404, "Page not found" ] unless post
	erb :edit, :locals => { :post => post, :url => post.url }
end

post '/past/:year/:month/:day/:slug/' do
	auth
  post = Post.by_slug(:key=>params[:slug], :count=>1).first
	stop [ 404, "Page not found" ] unless post
	post.title = params[:title]
	post.tags = parse_tags(params[:tags])
	post.body = params[:body]
	post.save
	redirect post.url
end

