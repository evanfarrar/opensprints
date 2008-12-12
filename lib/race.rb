class Race
  attr_accessor :racers
  def ==(other)
    racers==other.racers
  end

  def initialize(racers, distance)
    racers.compact.map{|r| r.ticks = 0}
    @racers = racers
    @distance = distance
  end

  def add_racer(racer)
    racer.ticks = 0
    racer.finish_time = nil
    @racers << racer
  end

  def complete?
    self.racers.all? { |racer| racer.finish_time }
  end

  def winner
    standings = self.racers.sort_by { |racer| racer.finish_time||Infinity }

    winner = standings.first
    standings.reverse.each_with_index do |racer, i|
      racer.wins += i if racer.finish_time
      racer.races += 1
      racer.record_time(racer.finish_time) if racer.finish_time
    end
    winner
  end

  def flip
    @racers.shuffle!
  end
end
