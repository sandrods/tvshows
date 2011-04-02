require 'rubygems'
require 'mechanize'
require 'rufus/scheduler'
require 'growl'
require 'eventmachine'
require 'eventmachine-tail'
#require 'em-dir-watcher'

require 'tvshows/logger'
require 'tvshows/episode'
require 'tvshows/series'
require 'tvshows/downloader'
require 'tvshows/subtitles'
require 'tvshows/extractor'

config = YAML.load_file("../config.yml")

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
  
  scheduler.cron "31 22 * * *" do

    config = YAML.load_file("../config.yml")

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
    config = YAML.load_file("../config.yml")
    Subtitles.new(config)
  end

end