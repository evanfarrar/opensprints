require 'enumerator'

#Tournament encapsulates a series of races and racers.
class Tournament
  #the racers available for racing
  # TODO: save eliminated racers somewhere
  attr_accessor :racers
  # races that have yet to be recorded.
  attr_accessor :matches
  # races that have finished and been recorded.
  attr_accessor :results

  # accepts distance, the length of the race in meters.
  def initialize(distance)
    @distance = distance
    @racers = []
    @matches = []
    @results = []
  end

  # Returns available racers who are not in a match.
  def racers_unmatched
    @racers - @matches.map{|m| m.racers }.flatten
  end

  # Takes all unmatched racers and places them in matches
  def autofill_matches
    self.racers_unmatched.each_slice(BIKES.length) { |a|
      @matches << (Race.new(a, @distance)) unless a.length == 1
    }
  end

  # Saves the results
  def record(race)
    results << race
    matches.reject!{|m| m == race}
  end

  # Add a racer to the first available match.
  def add_racer(racer)
    return if @matches.find{|m| m.racers.include?(racer) }
    unless (race=@matches.find{|m| m.racers.length < BIKES.length })
      race = Race.new([], @distance)
      @matches << race
    end
    race.add_racer(racer)
  end

  # The current lowest time of any racer in the tournament.
  def best_time
    racers.map { |racer| racer.best_time }.compact.min
  end

  # The match that is "on-deck" after a given race.
  def next_after(race)
    (matches-[race]).first
  end

end
