require 'rubygems'
require 'mechanize'
require 'data_mapper'
require 'dm-migrations'

%w(logger calendar downloader subtitles extractor scrappers/dighive scheduler models/episode models/show models/config).each do |file|
  require File.expand_path("../tvshows/#{file}", __FILE__)
end

require 'sinatra/base'

class TvShowsDaemon < Sinatra::Base


  configure do

    db = "sqlite3:///#{Dir.pwd}/tvshows.sqlite3"
    DataMapper.setup(:default, db)

    Episode.auto_migrate! unless Episode.storage_exists?
    Show.auto_migrate! unless Show.storage_exists?
    
    DataMapper.auto_upgrade!

    Settings.set_system_settings!

  end

  configure do
    
    enable :logging
    
    set :show_exceptions, true

    Scheduler.start!
  end

  set :views, File.dirname(__FILE__) + '/tvshows/views'
  set :public, File.dirname(__FILE__) + '/tvshows/public'

  get "/shows" do
    Show.all.map {|s| s.name }.join("<br/>")
  end
 
 get "/show/:name" do |name|
   Show.create(:name=>name)
   redirect '/shows'
 end

end
