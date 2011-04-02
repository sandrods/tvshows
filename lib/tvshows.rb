require 'rubygems'
require 'mechanize'
require 'growl'

%w(logger episode calendar downloader subtitles extractor scrappers/dighive scheduler).each do |file|
  require File.expand_path("../tvshows/#{file}", __FILE__)
end

require 'sinatra/base'

class TvShowsDaemon < Sinatra::Base

  configure do
    
    enable :logging
    
    set :show_exceptions, true

    Scheduler.start!
  end

  # This can display a nice status message.
  #
  get "/" do
    "#{Time.now} - Your skinny daemon is up and running."
  end

  # This POST allows your other apps to control the service.
  #
  post "/do-something/:great" do
    # something great could happen here
  end  

end
