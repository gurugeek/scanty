require 'xmlrpc/client'
require 'hpricot'

class Pingr
  @@method = 'weblogUpdates.extendedPing'
  def initialize(file_name)
    @services = []
    @log = []
    @log_folder = File.dirname(__FILE__) + "/../" + Blog.log_folder 
    Dir.mkdir(@log_folder) unless File.directory?(@log_folder)
    @log_file = @log_folder + "/ping_log.txt"
    doc = open(file_name) do |f|
      Hpricot(f)
    end     
    doc.search('service').each do |service|
      @services << {:host=>service['url'],:path=>service['path']}
    end
  end
  
  def execute
    @services.each do |service|
      begin
        call(:host=>service[:host],:path=>service[:path],:timeout=>10)
        @log << "#{Time.now} - - #{service[:host]} at #{service[:path]} successfully pinged"
      rescue => ex
        @log << "#{Time.now} - - error with #{service[:host]} -- #{ex.class} - #{ex.message}"
      end
    end
    File.open(@log_file,"a") do |log|
      log.puts(@log.join("\n"))
    end
  end
  
  def call(args)
    client = XMLRPC::Client.new3(:host=>args[:host],:path=>args[:path],:timeout=>args[:timeout])
    # Assumes this is used within the Scanty blog engine. Blog information
    # contained within the app_config file which is required in Main.rb
    client.call(@@method,Blog.title,Blog.url_base,Blog.url_base,Blog.url_base + 'feed')
  end
end

