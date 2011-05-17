class Episode
  include DataMapper::Resource

  property :id,         Serial

  property :title,      String,  :length  => (1..254)
  property :season,     String,  :length  => (1..2)
  property :number,     String,  :length  => (1..6)

  property :torrent_done,   DateTime
  property :subtitle_done,  DateTime

  belongs_to :show

  def self.missing(what = :any)
    case what
      when :torrent
        all(:torrent_done => nil)
      when :subtitle
        all(:subtitle_done => nil)
      when :any
        all(:subtitle_done => nil) + all(:torrent_done => nil)
      else
        []
    end
  end

  def self.missing?(what = :any)
    !missing(what).empty?
  end

  def done!(what = :all)
    case what
      when :torrent
        self.torrent_done  = Time.now
      when :subtitle
        self.subtitle_done = Time.now
      when :all
        self.subtitle_done = Time.now
        self.torrent_done  = Time.now
      else
        []
    end
    self.save
  end

  def set_ep(txt)
    txt =~ /S: (\d+) - Ep: (\d+) \((.+)\) - (.*)/
    self.season = $1.to_i
    self.number = $2.to_i
  end

  def set_show(show_name)
    show = Show.first_or_create(:name => show_name)
    self.show = show
  end

  def torrent_regex
    @torrent_regex ||= Regexp.new("(?!.*(720|264))(=#{self.show_name}.*#{self.number_txt}.*HDTV)", Regexp::IGNORECASE)
  end

  def subtitle_link_regex
    @subtitle_link_regex ||= Regexp.new("^#{self.show_name}.*#{self.number_txt}", Regexp::IGNORECASE)
  end

  def subtitle_file_regex
    @subtitle_file_regex ||= Regexp.new("(?!.*(720|264))#{self.show_name}.*\.srt", Regexp::IGNORECASE)
  end

  def number_txt
    _ep     = self.number.to_s.rjust(2, '0')
    _season = self.season.to_s.rjust(2, '0')

    "S#{_season}E#{_ep}"
  end
  
  def folder_name
    _season = self.season.to_s.rjust(2, '0')
    "#{self.show.name}.S#{_season}"
  end

  def show_name
    self.show.name.split.join(".")
  end

  def to_s
    "#{self.show.name}: #{self.number_txt} - #{self.title}"
  end
  
  def save_unless_exists
    save unless Episode.first(:season => self.season, :number => self.number, :show_id => self.show_id)
  end

  def self.get_folder_by_filename(file_name)
    file_name = File.basename(File.dirname(file_name))
    show = Show.get_by_filename(file_name)
    if ep = parse_filename(file_name)
      _season = ep[:season].to_s.rjust(2, '0')
      return "#{show.name}.S#{_season}"
    else
      return show.name
    end
  end

  def self.find_by_filename(filename, show)
    show = Show.get_by_filename(filename) unless show
    if ep = parse_filename(filename)
      show.episodes.first(:season => ep[:season], :number => ep[:number])
    else
      nil
    end
  end

  private
  
  def self.parse_filename(filename)
    if filename =~ /^([\w\.]+)\.(S(\d\d)E(\d\d)|(\d)(\d\d))/i
      {:show => $1, :season => ($3 || $5), :number => $4 || $6}
    else
      nil
    end
  end

end