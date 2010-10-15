class Downloader

  PATH = "/Users/sandro/Downloads/torrents/"

  def initialize(_files)
    @agent = WWW::Mechanize.new
    
    @files = _files
    @counter = 0

    login
  end

  def login

    Logger.log "Trying to login...", 'Digital Hive'

    page = @agent.get('http://www.digitalhive.org/login.php')

    form = page.forms[0]
    form.username = "sandrods"
    form.password = "328791"

    @agent.submit(form)

    #Logger.log "Login Sucessfull", 'Digital Hive'

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
      Logger.log "(#{@counter}) Verifying #{ep.regex.source}", 'Digital Hive'

      if link = page_links.detect{|l| l.href.match(ep.regex) }
        torrent = link.click
        torrent.save("#{PATH}#{torrent.filename}")
        
        Logger.log "Saving #{link.href}", 'Digital Hive'
        
        ep.done = true
      end
    end
  end
  
  def done?
    !@files.detect{ |ep| ep.done == false}
  end
  
end