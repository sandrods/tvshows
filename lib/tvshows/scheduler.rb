require 'rufus/scheduler'
require 'eventmachine'
require 'eventmachine-tail'

class Scheduler

  def Scheduler.start!
    
    Thread.new do
      until EventMachine.reactor_running?
        sleep 1
      end
    
      config = YAML.load_file(File.expand_path("../../config.yml", __FILE__))

      EventMachine.run do

        Watcher.new("#{config[:base_path]}/**/*.rar", config)

        scheduler = Rufus::Scheduler.start_new

        scheduler.cron "56 23 * * *" do

          Logger.log "scheduler.cron", "DEBUG"

          Calendar.new(config).get_episodes!

          if Episode.has_to_do?

            downloader = Downloader.new(config)

            scheduler.every("10m", :first_in => "0m") do |job|
              downloader.run
              if Episode.all_done?
                job.unschedule
                Logger.log "Exiting...", "SCRAPPER"
              end
            end

          end

        end

        scheduler.every "1h", :first_in => "0m" do
          Subtitles.new(config)
        end

      end # EventMachine

    end # Thread
  
  end # start!

end # class

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