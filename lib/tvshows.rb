require 'rubygems'
require 'mechanize'
require 'data_mapper'
require 'dm-migrations'

%w(
  logger
  scheduler

  torrent/calendar 
  torrent/downloader 
  torrent/extractor 
  torrent/scrappers/dighive 
  
  subtitle/downloader   
  
  models/episode
  models/show 
  models/settings

).each do |file|
  require File.expand_path("../tvshows/#{file}", __FILE__)
end

require 'sinatra/base'

class TvShowsDaemon < Sinatra::Base


  configure do

    db_file = File.expand_path("../../tvshows.sqlite3", __FILE__)
    db = "sqlite3:///#{db_file}"
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

 
  get "/episodes" do
   erb :episodes
  end

  get "/settings" do
   erb :settings
  end

  get "/settings/reset" do
   Settings.destroy
   Settings.set_system_settings!
   redirect "/settings"
  end

  post "/settings" do
   Settings.update_all(params[:name], params[:value])
   redirect "/settings"
  end

  get "/shows" do
    erb :shows
  end

  get "/shows/reset" do
   Show.destroy
   redirect "/shows"
  end
end
