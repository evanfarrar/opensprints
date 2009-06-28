class Tournament
  include DataMapper::Resource
  property :id, Serial
  has n, :races

  has n, :tournament_participations
  has n, :racers, :through => :tournament_participations, :mutable => true
end
