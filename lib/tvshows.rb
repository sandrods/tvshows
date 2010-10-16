require 'rubygems'
require 'mechanize'
require 'rufus/scheduler'
require 'growl'
require 'eventmachine'

require 'tvshows/episode'
require 'tvshows/series'
require 'tvshows/logger'
require 'tvshows/downloader'
require 'tvshows/subtitles'


EventMachine.run do

  scheduler = Rufus::Scheduler.start_new

  scheduler.cron "0 22 * * *" do

    s = Series.new
    eps = s.episodes

    unless eps.empty?
      d = Downloader.new(eps)

      scheduler.every "10m", :first_in => "0m" do
        d.run
        scheduler.stop if d.done?
      end

    end

  end

  scheduler.every "2h", :first_in => "0m" do
    Subtitles.new(YAML.load_file("../subs.config.yml"))
  end

end