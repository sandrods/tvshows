module Subtitle

  class Downloader

    #URL = "http://194.14.79.53"
    URL = "http://legendas.tv"

    def initialize()
      @agent = WWW::Mechanize.new
      login
      download

    rescue Exception => e
      Logger.log e.message, "SUBTITLES ERR"

    end

    def login

      Logger.log "Logging in...", "SUBTITLES"

      page = @agent.get(URL)

      f = page.form_with(:action => 'login_verificar.php') do |form|
        form.txtLogin = Settings[:subtitles_username]
        form.txtSenha = Settings[:subtitles_password]
        form['chkLogin'] = "1"
      end
      button = f.button(:value=>"Entrar")

      f.submit(button)
   
    end

    def get_links
      ret = {}
      page = @agent.get("#{URL}/destaques.php?show=2")
      page./("div.Ldestaque").each do |div|
        nome = $1 if div['onmouseover']=~/gpop\('(?:.*','){2}(.*)','(.*','){5}/
        id = $1 if div['onclick']=~/javascript:abredown\('(.*)'\);/
        ret[nome] = id
      end

      # page = @agent.get("#{URL}/destaques.php?show=2&start=24")

      ret
    end

    def download
      links = get_links
    
      Episode.subtitle_to_do.each do |ep|
        if names = links.keys.select{|l| l.match(ep.subtitle_link_regex)}
          names.each do |name|
            id = links[name]
            url = "#{URL}/info.php?d=#{id}&c=1"
            file = @agent.get(url)
            file.save
            ep.subtitle_done!
            extract_file(file.filename, ep)
          end
        end
      end

    end

    def extract_file(file_name, ep)
      folder = "#{Time.now.to_f}.tmp"
      FileUtils.mkdir_p(folder)
      FileUtils.mv(file_name, folder)
      Dir.chdir(folder)

      unzip_file(file_name)
    
      files = Dir["*.srt"]

      if st = files.detect { |f| f =~ ep.subtitle_file_regex }
        FileUtils.cp st, File.expand_path(ep.show_name, Settings[:base_path])
        Logger.log "#{st} extracted", "SUBTITLE FOUND", true
      else
        Logger.log "#{file_name} downloaded, but no subtitle matched: #{files.join("\n")}", "SUBTITLES", true
      end
      Dir.chdir("..")
      FileUtils.rm_rf(folder)
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