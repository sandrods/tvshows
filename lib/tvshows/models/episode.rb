class Episode
  include DataMapper::Resource

  attr_accessor :series, :title, :season, :ep, :time, :ep_txt, :done

  # Properties
  #
  property :id,     Serial
  property :title,  String,  :length  => (1..254)
  property :season, String,  :length  => (1..2)
  property :number, String,  :length  => (1..6)
  property :done,   Boolean, :default => false
  
  

  # Associations
  #
  belongs_to :show

end