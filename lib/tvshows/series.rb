
class Series

  def initialize
    @agent = WWW::Mechanize.new
    login
  end

  def login

    Logger.log "Trying to login...", 'Calendar'

    page = @agent.get('http://www.pogdesign.co.uk/cat/')

    f = page.form_with(:action => '/cat/') do |form|
      form.username = "sandrods@gmail.com"
      form.password = "328791"
    end
    button = f.button(:value=>"Account Login")

    f.submit(button)

    # Logger.log "Login Sucessfull...", 'Calendar'

  end
  
  def episodes(_date = nil)

    eps = []
    date = _date ? Date.parse(_date) : Date.today - 8
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
      Logger.log "NOTHING", 'Airs Today', true
    else
      eps.each do |e| 
        Logger.log e.to_s, 'Airs Today', true
#        Logger.log e.ai, 'Airs Today', true
      end
    end
    
    eps
  end
  
end