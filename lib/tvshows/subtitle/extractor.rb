module Subtitle

  class Extractor

    def initialize(file_name, episode)
      @file_name = file_name
      @episode = episode
    end

    def extract!

      move_to_tmp_folder(@file_name)

      unzip_file(@file_name)

      files = Dir["*.srt"]

      if st = files.detect { |f| f =~ @episode.subtitle_file_regex }

        FileUtils.cp st, File.expand_path(@episode.folder_name, Settings[:base_path])
        Logger.log "#{st} extracted", "SUBTITLE FOUND", true

      else
        Logger.log "#{file_name} downloaded, but no subtitle matched: #{files.join("\n")}", "SUBTITLES", true
      end

      Dir.chdir("..")
      FileUtils.rm_rf(folder)
    end

  private 

    def move_to_tmp_folder(file_name)
      folder = "#{Time.now.to_f}.tmp"
      FileUtils.mkdir_p(folder)
      FileUtils.mv(file_name, folder)
      Dir.chdir(folder)
    end

    def unzip_file(file_name)
      ext = File.extname(file_name).downcase
      case ext
      when ".rar"
        %x(unrar e #{file_name})
      when ".zip"
        %x(unzip #{file_name})
      end
    end

  end

end