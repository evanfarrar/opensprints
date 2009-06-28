class Racer
  include DataMapper::Resource
  property :id, Serial
  property :name, String

  has n, :race_participations
  has n, :races, :through => :race_participations
  has n, :tournament_participations
  has n, :tournaments, :through => :tournament_participations
end
