require 'rufus/scheduler'
require 'eventmachine'
require 'eventmachine-tail'

class Scheduler

  def Scheduler.start!
    
    Thread.new do
      until EventMachine.reactor_running?
        sleep 1
      end

      EventMachine.run do

        #Watcher.new("#{Settings[:base_path]}/**/*.rar")

        scheduler = Rufus::Scheduler.start_new

        scheduler.cron "56 23 * * *" do

          Logger.log "scheduler.cron", "DEBUG"

          Torrent::Calendar.new.get_episodes!

          if Episode.any_torrent_missing?

            downloader = Torrent::Downloader.new

            scheduler.every("10m", :first_in => "0m") do |job|
              downloader.run
              if Episode.no_torrent_missing?
                job.unschedule
                Logger.log "Exiting...", "SCRAPPER"
              end
            end

          end

        end

        scheduler.every "1h", :first_in => "0m" do
          Subtitle::Downloader.new if Episode.any_subtitle_missing?
        end

      end # EventMachine

    end # Thread
  
  end # start!

end # class

class Watcher < EventMachine::FileGlobWatch
  def initialize(pathglob, interval=60)
    super(pathglob, interval)
  end

  def file_found(file)
    Torrent::Extractor.new.extract(file)
  end

  def file_deleted(file)
  end

end # class Watcher