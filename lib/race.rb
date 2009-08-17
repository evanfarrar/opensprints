class Race
  include DataMapper::Resource
  property :id, Serial
  has n, :race_participations
  #has n, :racers, :through => :race_participations, :mutable => true
  belongs_to :tournament

  def racers
    race_participations.map(&:racer)
  end

  def winner
    standings = self.race_participations.sort_by { |racer| racer.finish_time||Infinity }
    standings.first
  end
end
