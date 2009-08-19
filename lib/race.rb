class Race
  include DataMapper::Resource
  property :id, Serial
  has n, :race_participations
  belongs_to :tournament

  def racers
    race_participations.map(&:racer)
  end

  def winner
    standings = self.race_participations.sort_by { |racer| racer.finish_time||Infinity }
    standings.first
  end

  def finished?
    race_participations.all?(&:finish_time)
  end
end
