class Downloader

  def initialize(_config, _files)
    @files = _files
    @counter = 0

    @scrapper = Scrapper::DigitalHive.new(_config)
  end

  def run
    #Logger.log "Running", 'Digital Hive'
    @counter +=1

    @scrapper.update_links!

    @files.each do |ep|
      next if ep.done
      Logger.log "(#{@counter}) Verifying -> #{ep.to_s}", 'SCRAPPER'

      if @scrapper.find_episode?(ep)

        @scrapper.save_torrent(PATH)
        Logger.log "Saving #{@scrapper.filename}", 'DOWNLOAD TORRENT'
        
        ep.done = true
      end

    end

  rescue Exception => e
    Logger.log e.message, "SCRAPPER ERR"
  end
  
  def done?
    !@files.detect{ |ep| ep.done == false}
  end
  
end