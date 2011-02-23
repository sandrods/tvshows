
class Series

  def initialize(config)
    @config = config
    @agent = WWW::Mechanize.new
    login
  end

  def login

    Logger.log "Trying to login...", 'CALENDAR'

    page = @agent.get('http://www.pogdesign.co.uk/cat/')

    f = page.form_with(:action => '/cat/') do |form|
      form.username = @config[:login][:calendar][:username]
      form.password = @config[:login][:calendar][:password]
    end
    button = f.button(:value=>"Account Login")

    f.submit(button)

    # Logger.log "Login Sucessfull...", 'Calendar'

  end
  
  def episodes(_date = nil)

    eps = []
    date = _date ? Date.parse(_date) : Date.today
    url_month = date.month.to_s + "-" + date.year.to_s
    td_id = "d_#{date.day}_#{date.month}_#{date.year}"

    #Logger.log "Running...", 'Calendar'

    page = @agent.get("http://www.pogdesign.co.uk/cat/#{url_month}")
    
    page./("td##{td_id} a.eplink").each do |node|
      ep = Episode.new
      td = node.parent
      ep.series = td./("a").text
      ep.title = td./("span.seasep")[0].text
      ep.set_ep(td./("span.seasep")[1].text)
      eps << ep
    end
    if eps.empty?
      Logger.log "NOTHING", 'CALENDAR - Today', true
    else
      eps.each do |e| 
        Logger.log e.to_s, 'CALENDAR - Today', true
      end
    end
    
    eps
  end
  
end