class Subtitles

  #URL = "http://194.14.79.53"
  URL = "http://legendas.tv"

  def initialize(config)
    @config = config
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
      form.txtLogin = @config[:login][:legendas][:username]
      form.txtSenha = @config[:login][:legendas][:password]
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
    # page./("div.Ldestaque").each do |div|
    #   nome = $1 if div['onmouseover']=~/gpop\('(?:.*','){2}(.*)','(.*','){5}/
    #   id = $1 if div['onclick']=~/javascript:abredown\('(.*)'\);/
    #   ret[nome] = id
    # end

    ret
  end

  def download
    links = get_links
    @config[:shows].each do |leg|
      rex = Regexp.new(leg['link_regex'], Regexp::IGNORECASE)
      if names = links.keys.select{|l| l.match(rex)}
        names.each do |name|
          if was_not_downloaded?(name)
            id = links[name]
            file = @agent.get("#{URL}/info.php?d=#{id}&c=1")
            file.save
            log_download!(name)
            extract_file(file.filename, leg)
          end
        end
      end
    end
  end

  def extract_file(file_name, leg)
    folder = "#{Time.now.to_f}.tmp"
    FileUtils.mkdir_p(folder)
    FileUtils.mv(file_name, folder)
    Dir.chdir(folder)

    unzip_file(file_name)

    files = Dir["*.srt"]

    rex = Regexp.new(leg['subtitle_regex'], Regexp::IGNORECASE)
    if st = files.detect { |f| f =~ rex }
      copy_to = File.expand_path(leg['folder'], @config[:base_path])
      FileUtils.cp st, copy_to
      Logger.log "#{st} extracted", "SUBTITLE FOUND", true

      rename_video_file(st, copy_to)
    else
      Logger.log "#{file_name} downloaded, but no subtitle matched: #{files.join("\n")}", "SUBTITLES", true
    end
    Dir.chdir("..")
    FileUtils.rm_rf(folder)
  end

  def log_download!(name)
    time = Time.now.strftime("%d/%m/%Y %H:%M:%S")
    File.open("downloaded.log", 'a') do |f|
      f.write("#{time} - #{name}\n")
    end
  end

  def was_not_downloaded?(name)
    #return true unless File.exist?("downloaded.log")
    lines = []

    File.open("downloaded.log", 'r') { |f| lines = f.readlines }

    lines.detect {|line| line.include?(name) }.nil?
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

  def rename_video_file(st, dir)

    if st =~ /S(\d\d)E(\d\d)/i
      s, e = $1.to_i, $2.to_i
      rex = Regexp.new("#{s}#{e}")
      files = Dir["#{dir}/*.avi"]
      if avi = files.detect { |f| f =~ rex }
        new_name = File.join(dir, st.gsub(".srt", ".avi"))
        FileUtils.mv(avi, new_name)
        Logger.log "#{File.basename(avi)} renamed to #{File.basename(new_name)}", "SUBTITLE FOUND", true
      end

    end

  end


end