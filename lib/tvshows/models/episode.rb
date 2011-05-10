class Episode
  include DataMapper::Resource

  property :id,         Serial

  property :title,      String,  :length  => (1..254)
  property :season,     String,  :length  => (1..2)
  property :number,     String,  :length  => (1..6)

  property :torrent_done,   DateTime
  property :subtitle_done,  DateTime

  belongs_to :show

  def self.torrent_missing
    all(:torrent_done => nil)
  end

  def self.subtitle_missing
    all(:subtitle_done => nil)
  end


  def self.any_torrent_missing?
    !Episode.torrent_missing.empty?
  end

  def self.no_torrent_missing?
    Episode.torrent_missing.empty?
  end


  def self.any_subtitle_missing?
    !Episode.subtitle_missing.empty?
  end

  def self.no_subtitle_missing?
    Episode.subtitle_missing.empty?
  end
  
  def self.to_do
    Episode.torrent_missing + Episode.subtitle_missing
  end


  def set_ep(txt)
    txt =~ /S: (\d+) - Ep: (\d+) \((.+)\) - (.*)/
    self.season = $1
    self.number = $2
  end

  def set_show(show_name)
    show = Show.first_or_create(:name => show_name)
    self.show = show
  end

  def torrent_regex
    Regexp.new("(?!.*(720|264))(=#{self.show_name}.*#{self.number_txt}.*HDTV)", Regexp::IGNORECASE)
  end

  def subtitle_link_regex
    Regexp.new("^#{self.show_name}.*#{self.number_txt}", Regexp::IGNORECASE)
  end

  def subtitle_file_regex
    Regexp.new("(?!.*(720|264))#{self.show_name}.*\.srt", Regexp::IGNORECASE)
  end

  def number_txt
    _ep     = self.number.to_s.rjust(2, '0')
    _season = self.season.to_s.rjust(2, '0')

    "S#{_season}E#{_ep}"
  end

  def show_name
    self.show.name.split.join(".")
  end

  def to_s
    "#{self.show.name}: #{self.number_txt} - #{self.title}"
  end

  def torrent_done!
    self.torrent_done = Time.now
    self.save
  end

  def subtitle_done!
    self.subtitle_done = Time.now
    self.save
  end
  
  def save_unless_exists
    save unless Episode.first(:season => self.season, :number => self.number, :show_id => self.show_id)
  end
  

end