class Subtitles

  def initialize(config)
    @config = config
    @agent = WWW::Mechanize.new
    login
    download
  end

  def login

    Logger.log "Logging in...", "GET SUBTITLES"

    page = @agent.get('http://www.legendas.tv')

    f = page.form_with(:action => 'login_verificar.php') do |form|
      form.txtLogin = @config[:login][:username]
      form.txtSenha = @config[:login][:password]
      form['chkLogin'] = "1"
    end
    button = f.button(:value=>"Entrar")

    f.submit(button)

  end

  def get_links
    ret = {}
    page = @agent.get('http://www.legendas.tv/destaques.php')
    page./("div.Ldestaque").each do |div|
      nome = $1 if div['onmouseover']=~/gpop\('(?:.*','){2}(.*)','(.*','){5}/
      id = $1 if div['onclick']=~/javascript:abredown\('(.*)'\);/
      ret[nome] = id
    end
    ret
  end
  
  def download
    links = get_links
    @config[:shows].each do |leg|
      rex = Regexp.new(leg['link_regex'], Regexp::IGNORECASE)
      if name = links.keys.detect{|l| l.match(rex)}
        if was_not_downloaded?(name)
          id = links[name]
          file = @agent.get("http://www.legendas.tv/info.php?d=#{id}&c=1")
          file.save
          log_download!(name)
          extract_file(file.filename, leg)
        end
      end
    end
  end
  
  def extract_file(file_name, leg)
    folder = "#{Time.now.to_f}.tmp"
    FileUtils.mkdir_p(folder)
    FileUtils.mv(file_name, folder)
    Dir.chdir(folder)

    %x(unrar e #{file_name})
    
    files = Dir["*.srt"]

    rex = Regexp.new(leg['subtitle_regex'], Regexp::IGNORECASE)
    if st = files.detect { |f| f =~ rex }
      FileUtils.cp st, File.expand_path(leg['folder'], @config[:base_path])
      Logger.log "#{st} extracted", "GET SUBTITLES", true
    else
      Logger.log "#{file_name} downloaded, but no subtitle matched: #{files.join("\n")}", "GET SUBTITLES", true
    end
    Dir.chdir("..")
    FileUtils.rm_rf(folder)
  end

  def log_download!(name)
    File.open("downloaded.log", 'a') do |f|
      f.write("#{name}\n")
    end
  end

  def was_not_downloaded?(name)
    return true unless File.exist?("downloaded.log")
    lines = []
    File.open("downloaded.log", 'r') do |f|
      lines = f.readlines
    end
    !lines.include?("#{name}\n")
  end

end