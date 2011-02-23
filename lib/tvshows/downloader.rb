class Downloader

  PATH = "/Users/sandro/Downloads/torrents/"

  def initialize(_config, _files)
    @config = _config
    @agent = WWW::Mechanize.new
    
    @files = _files
    @counter = 0

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
  
  def get_links
    page = @agent.get('http://www.digitalhive.org/browse.php?cat=7')
    page.links_with(:text => 'Download')    
  end

  def run
    #Logger.log "Running", 'Digital Hive'
    @counter +=1
    page_links = get_links
    
    @files.each do |ep|
      next if ep.done
      Logger.log "(#{@counter}) Verifying -> #{ep.to_s}", 'DIGITAL HIVE'

      if link = page_links.detect{|l| l.href.match(ep.regex) }
        torrent = link.click
        torrent.save("#{PATH}#{torrent.filename}")
        
        Logger.log "Saving #{torrent.filename}", 'DOWNLOAD TORRENT'
        
        ep.done = true
      end
    end

  rescue Exception => e
    Logger.log e.message, "DIGITAL HIVE ERR"
  end
  
  def done?
    !@files.detect{ |ep| ep.done == false}
  end
  
end