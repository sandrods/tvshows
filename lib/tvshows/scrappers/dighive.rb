module Scrapper
  class DigitalHive
  
    attr_accessor :filename

    def initialize(config)
      @agent = WWW::Mechanize.new
      @config = config
      login
    end

    def login

      Logger.log "Trying to login...", 'DIGITAL HIVE'

      page = @agent.get('http://www.digitalhive.org/login.php')

      form = page.forms[0]
      form.username = @config[:login][:digitalhive][:username]
      form.password = @config[:login][:digitalhive][:password]

      @agent.submit(form)

      #Logger.log "Login Sucessfull", 'Digital Hive'

    rescue Exception => e
      Logger.log e.message, "DIGITAL HIVE ERR"
    end

    def update_links!
      page = @agent.get('http://www.digitalhive.org/browse.php?cat=7')
      @episodes = page.links_with(:text => 'Download')    
    end

    def find_episode?(ep)
      @link = @episodes.detect{|l| l.href.match(ep.regex) }
      !@link.nil?
    end

    def save_torrent
      path = @config[:torrent_save_path]
    
      torrent = @link.click
      torrent.save("#{path}#{torrent.filename}")

      @filename = torrent.filename
    end

  end
end