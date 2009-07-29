class Tournament
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  has n, :races

  has n, :tournament_participations
  has n, :racers, :through => :tournament_participations, :mutable => true
end
