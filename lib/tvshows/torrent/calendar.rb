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
        form.username = Config[:calendar_username]
        form.password = Config[:calendar_password]
      end
      button = f.button(:value=>"Account Login")

      f.submit(button)

      # Logger.log "Login Sucessfull...", 'Calendar'

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
  
  end

end