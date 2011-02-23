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
    if show = @config[:shows].detect { |d| show_name.match(Regexp.new(d['link_regex'], Regexp::IGNORECASE)) }
      return File.expand_path(show['folder'], @config[:base_path])
    else
      Logger.log "Folder for #{show_name} not found", "EXTRACTOR", true
      return false
    end
  end

end