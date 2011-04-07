module Torrent

  class Extractor

    def initialize(config)
      @config = config
    end

    def extract(file_name)
      fname = File.basename(file_name)
      Logger.log "Extracting file #{fname}", "EXTRACTOR"
      if folder = get_show_folder(file_name)
        %x(unrar e '#{file_name}' '#{folder}' -y)
        Logger.log "File extracted to #{folder}", "EXTRACTED", true
      end

    end

    private
  
    def get_show_folder(file_name)
    
      show_name = File.basename(File.dirname(file_name))
      if folder = Show.get_folder_by_filename(show_name)
        return File.expand_path(folder, @config[:base_path])
      else
        Logger.log "Folder for #{show_name} not found", "EXTRACTOR", true
        return false
      end
    end

  end

end