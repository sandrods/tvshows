BASE = File.expand_path(File.dirname(__FILE__))

require 'rubygems'
require 'mechanize'
require 'rufus/scheduler'
require 'eventmachine'
require 'eventmachine-tail'
require 'yaml'

require File.join(BASE, 'tvshows', 'logger')
require File.join(BASE, 'tvshows', 'episode')
require File.join(BASE, 'tvshows', 'series')
require File.join(BASE, 'tvshows', 'extractor')
require File.join(BASE, 'tvshows', 'downloader')
require File.join(BASE, 'tvshows', 'subtitles')

Logger.log "Loading..." , "TV SHOWS"

config = YAML.load_file(File.expand_path(File.join(BASE, '..', 'config.yml')))

class Watcher < EventMachine::FileGlobWatch
  def initialize(pathglob, config, interval=60)
    @conf = config
    super(pathglob, interval)
  end

  def file_found(file)
    #Logger.log(file)
    ::Extractor.new(@conf).extract(file)
  end

  def file_deleted(file)
  end

end # class Watcher

EventMachine.run do
  
  Logger.log "Starting..." , "TV SHOWS"
  
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
  
  scheduler.cron "18 23 * * *" do

    config = YAML.load_file(File.expand_path(File.join(BASE, '..', 'config.yml')))

    eps = Series.new(config).episodes
      
    unless eps.empty?
      download = Downloader.new(config, eps)
      
      scheduler.every("10m", :first_in => "30m") do |job|
        download.run

        if download.done? || download.expired?
          job.unschedule
          Logger.log "Exiting..."           , "DIGITAL HIVE" if download.done? 
          Logger.log "Quiting (TIMEOUT)..." , "DIGITAL HIVE" if download.expired? 
        end

      end
      
    end
  
  end
  
  scheduler.every "1h", :first_in => "0m" do
    config = YAML.load_file(File.expand_path(File.join(BASE, '..', 'config.yml')))
    Subtitles.new(config)
  end

end