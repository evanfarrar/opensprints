class RaceParticipation
  attr_accessor :ticks
  include DataMapper::Resource
  property :id, Serial

  belongs_to :racer
  belongs_to :race

  property :finish_time, BigDecimal

  def color
    $BIKES[self.race.race_participations.index(self)]
  end

  def speed(stubbed)
    31
  end

  def percent_complete
    [1.0, self.distance / $RACE_DISTANCE].min
  end

  def distance
    self.ticks * $ROLLER_CIRCUMFERENCE
  end
end
