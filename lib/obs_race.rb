# Represents data related to a race: it's participants, the winner,
# the length, and status.
class ObsRace
  # The participants of the race
  attr_accessor :racers
  # Two races are considered the same if their racers are the same.
  def ==(other)
    racers==other.racers
  end

  # initializes with an array of racers and the distance of the race.
  def initialize(racers, distance)
    racers.compact.map{|r| r.ticks = 0}
    @racers = racers
    @distance = distance
  end

  # Add a racer to the race (also clears out tick data on the racer).
  def add_racer(racer)
    racer.ticks = 0
    racer.finish_time = nil
    @racers << racer
  end

  # Is the race done yet?
  def complete?
    self.racers.all? { |racer| racer.finish_time }
  end

  # The winner of the race
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

  # Not really used any more...obseleted by the racer->bike matching
  # interface
  # FIXME: delete?
  def flip
    @racers.shuffle!
  end

  # For a given racer, returns a number 0-1.0, 0 representing not started
  # and 1.0 representing the full race distance. Use this to fill progress
  # bars, move clock hands, etc.
  def percent_complete(racer)
    [1.0, ((racer.distance) || 0)/@distance.to_f].min
  end
end
