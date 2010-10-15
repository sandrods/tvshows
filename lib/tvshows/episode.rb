class Episode
  attr_accessor :series, :title, :season, :ep, :time, :ep_txt, :done

  def initialize
    @done = false
  end

  def set_ep(txt)
    txt =~ /S: (\d+) - Ep: (\d+) \((.+)\) - (.*)/
    @season = $1
    @ep = $2
    @time = $3
    
    _ep = @ep.to_s.rjust(2, '0')
    _season = @season.to_s.rjust(2, '0')
    @ep_txt = "S#{_season}E#{_ep}"
  end

  def regex
    name = self.series.split.join(".")
    Regexp.new("(?!.*(720|264))(=#{name}.*#{@ep_txt}.*HDTV)", Regexp::IGNORECASE)
  end

  def to_s
    "#{self.series}\n#{self.ep_txt} - #{self.title}"
  end

end