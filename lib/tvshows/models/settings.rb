class Settings
  include DataMapper::Resource

  property :id,         Serial

  property :name,      String
  property :value,     String

  def self.[](name)
    Settings.first(:name => name.to_s)
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
      Settings.first_or_create(:name => s)
    end
  end
  
  def self.update_all(names, values)
    names.each_with_index do |name, i|
      Settings[name].update(:value => values[i])
    end
  end

end