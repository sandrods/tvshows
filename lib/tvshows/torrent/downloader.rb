module Torrent

  class Downloader

    def initialize()
      @counter = 0

      @scrapper = Scrapper::DigitalHive.new()
    end

    def run
      #Logger.log "Running", 'Digital Hive'
      @counter +=1

      @scrapper.update_links!

      Episode.torrent_to_do.each do |ep|
        Logger.log "(#{@counter}) Verifying -> #{ep.to_s}", 'SCRAPPER'

        if @scrapper.find_episode?(ep)

          @scrapper.save_torrent(Config[:torrent_save_path])
          Logger.log "Saving #{@scrapper.filename}", 'DOWNLOAD TORRENT'
        
          ep.torrent_done!
        end

      end

    rescue Exception => e
      Logger.log e.message, "SCRAPPER ERR"
    end

  end

end