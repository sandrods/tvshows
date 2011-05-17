module Subtitle

  class Downloader

    #URL = "http://194.14.79.53"
    URL = "http://legendas.tv"

    def initialize(episodes)
      @episodes = episodes
      @agent = Mechanize.new
    end
  
    def run!

      unless @episodes.empty?
        login
        get_links
        download
      end

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
      @links = {}
      page = @agent.get("#{URL}/destaques.php?show=2")
      page./("div.Ldestaque").each do |div|
        nome = $1 if div['onmouseover']=~/gpop\('(?:.*','){2}(.*)','(.*','){5}/
        id = $1 if div['onclick']=~/javascript:abredown\('(.*)'\);/
        @links[nome] = id
      end

      # page = @agent.get("#{URL}/destaques.php?show=2&start=24")

      @links
    end

    def download

      @episodes.each do |ep|
        if names = @links.keys.select{|l| l.match(ep.subtitle_link_regex)}
          names.each do |name|
            id = links[name]
            url = "#{URL}/info.php?d=#{id}&c=1"
            file = @agent.get(url)
            file.save
            ep.done!(:subtitle)
            
            Extractor.new(file.filename, ep).extract!

          end
        end
      end

    end

  end # class

end # module