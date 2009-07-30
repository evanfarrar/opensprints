class Tournament
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  has n, :races

  has n, :tournament_participations
  has n, :racers, :through => :tournament_participations, :mutable => true

  def racers
    tournament_participations.map(&:racer)
  end

  def autofill
    reload.racers.each_slice(2) { |a|
      races.create(:race_participations => a.map{|r| {:racer => r}})
    }
  end
end
