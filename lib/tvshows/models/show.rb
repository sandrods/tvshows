class Show
  include DataMapper::Resource

  property :id, Serial
  property :name, String, :required => true, :length => (1..254)
  
  has n, :episodes

  def link_regex
    name = self.name.split.join(".")
    Regexp.new("^#{name}", Regexp::IGNORECASE)
  end

end