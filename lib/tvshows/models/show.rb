class Show
  include DataMapper::Resource

  # Properties
  #
  property :id, Serial
  property :name, String, :required => true, :length => (1..254)
  

  # Associations
  #
  has n, :episodes

end