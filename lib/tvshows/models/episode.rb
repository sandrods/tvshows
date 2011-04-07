class Episode
  include DataMapper::Resource

  property :id,         Serial

  property :title,      String,  :length  => (1..254)
  property :season,     String,  :length  => (1..2)
  property :number,     String,  :length  => (1..6)

  property :torrent_done,   Boolean, :default => false
  property :subtitle_done,  Boolean, :default => false

  belongs_to :show

  def self.torrent_to_do
    all(:torrent_done => false)
  end

  def self.subtitle_to_do
    all(:subtitle_done => false)
  end


  def self.has_torrent_to_do?
    !Episode.torrent_to_do.empty?
  end

  def self.all_torrent_done?
    Episode.torrent_to_do.empty?
  end


  def self.has_subtitle_to_do?
    !Episode.subtitle_to_do.empty?
  end

  def self.all_subtitle_done?
    Episode.subtitle_to_do.empty?
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
    self.torrent_done = true
    self.save
  end

  def subtitle_done!
    self.subtitle_done = true
    self.save
  end

end