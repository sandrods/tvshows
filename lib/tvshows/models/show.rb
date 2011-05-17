class Show
  include DataMapper::Resource

  property :id, Serial
  property :name, String, :required => true, :length => (1..254)
  
  has n, :episodes

  def self.get_by_filename(file_name)
    Show.all.detect { |s| file_name.match(s.folder_regex) }
  end

  def folder_regex
    Regexp.new("^#{self.name.split.join('.')}", Regexp::IGNORECASE)
  end

  def self.update_all(names)
    names.each do |name|
      n = the_name(name)
      Show.first_or_create(:name => n)
    end
  end
  
  private 

  def self.the_name(name)
    if name =~ /(.*)\s?\[The\]/i
      "The #{$1}"
    else
      name
    end
  end

end