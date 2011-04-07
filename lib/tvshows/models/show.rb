class Show
  include DataMapper::Resource

  property :id, Serial
  property :name, String, :required => true, :length => (1..254)
  
  has n, :episodes
  
  def self.get_folder_by_filename(file_name)
    Show.all.detect { |s| file_name.match(s.folder_regex) }
  end

  def folder_regex
    Regexp.new("^#{self.name.split.join('.')}", Regexp::IGNORECASE)
  end

end