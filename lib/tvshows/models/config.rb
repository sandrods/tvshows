class Config
  include DataMapper::Resource

  property :id,         Serial

  property :name,      String
  property :value,     String

  def self.[](name)
    Config.first(:name => name.to_s)
  end

  def self.set_system_settings!
    %w(
      base_path 
      torrent_save_path

      subtitles_username
      subtitles_password

      torrents_username
      torrents_password

      calendar_username
      calendar_password
    ).each do |s|
      Config.first_or_create(:name => s)
    end
  end

end