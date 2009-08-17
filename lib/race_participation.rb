class RaceParticipation
  include DataMapper::Resource
  property :id, Serial

  belongs_to :racer
  belongs_to :race

  property :finish_time, BigDecimal

  def color
    BIKES[self.race.race_participations.index(self)]
  end
end
