require 'rubygems'
require 'mechanize'
require 'rufus/scheduler'
require 'growl'
require 'eventmachine'
require 'eventmachine-tail'
#require 'em-dir-watcher'

%w(logger episode series downloader subtitles extractor).each do |file|
  require File.expand_path("../tvshows/#{file}", __FILE__)
end

require 'sinatra/base'


class Watcher < EventMachine::FileGlobWatch
  def initialize(pathglob, config, interval=60)
    @conf = config
    super(pathglob, interval)
  end

  def file_found(file)
    #Logger.log(file)
    Extractor.new(@conf).extract(file)
  end

  def file_deleted(file)
  end

end # class Watcher

class TvShowsDaemon < Sinatra::Base

  configure do
    
    enable :logging
    
    set :show_exceptions, true

    Thread.new do
      until EventMachine.reactor_running?
        sleep 1
      end
      
      config = YAML.load_file(File.expand_path("../../config.yml", __FILE__))

      EventMachine.run do

        # Logger.log "Watching files on #{config[:base_path]}", "TV SHOWS"
        # EMDirWatcher.watch config[:base_path], :include_only => '*.rar' do |paths|
        #   paths.each do |path|
        #     file = File.join(config[:base_path], path)
        #     Extractor.new(config).extract(file) if File.exists? file
        #   end
        # end
        #
  
        Watcher.new("#{config[:base_path]}/**/*.rar", config)

        scheduler = Rufus::Scheduler.start_new

        scheduler.cron "56 23 * * *" do

          Logger.log "scheduler.cron", "DEBUG"
          eps = Series.new(config).episodes

          unless eps.empty?
            download = Downloader.new(config, eps)

            scheduler.every("10m", :first_in => "30m") do |job|
              download.run
              if download.done?
                job.unschedule
                Logger.log "Exiting...", "DIGITAL HIVE"
              end
            end

          end

        end

        scheduler.every "1h", :first_in => "0m" do
          Subtitles.new(config)
        end

      end

    end
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
