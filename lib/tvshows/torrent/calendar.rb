module Torrent

  class Calendar

    def initialize()
      @agent = WWW::Mechanize.new
      login
    end

    def login

      Logger.log "Trying to login...", 'CALENDAR'

      page = @agent.get('http://www.pogdesign.co.uk/cat/')

      f = page.form_with(:action => '/cat/') do |form|
        form.username = Settings[:calendar_username]
        form.password = Settings[:calendar_password]
      end
      button = f.button(:value=>"Account Login")

      f.submit(button)

    end
  
    def get_episodes!(_date = nil)

      eps = []
      date = _date ? Date.parse(_date) : Date.today
      url_month = date.month.to_s + "-" + date.year.to_s
      td_id = "d_#{date.day}_#{date.month}_#{date.year}"

      #Logger.log "Running...", 'Calendar'

      page = @agent.get("http://www.pogdesign.co.uk/cat/#{url_month}")
    
      page./("td##{td_id} a.eplink").each do |node|
        ep = Episode.new
        td = node.parent

        ep.set_show(td./("a").text)
        ep.set_ep(td./("span.seasep")[1].text)
        ep.title = td./("span.seasep")[0].text

        ep.save
      end
    end

    def get_shows
      ret = []
      Logger.log "Geting Shows...", 'Calendar'
      page = @agent.get("http://www.pogdesign.co.uk/cat/showselect.php")

      page./("//div[@class='checkedletter  ']//a").each do |node|
        ret << node.text
      end
      
      ret
    end
  
  end

end