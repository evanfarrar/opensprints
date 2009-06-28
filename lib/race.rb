class Race
  include DataMapper::Resource
  property :id, Serial
  has n, :race_participations
  has n, :racers, :through => :race_participations, :mutable => true
  belongs_to :tournament
end
