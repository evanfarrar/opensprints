require 'enumerator'

class Tournament
  attr_accessor :racers
  attr_accessor :matches
  attr_accessor :results

  def initialize(distance)
    @distance = distance
    @racers = []
    @matches = []
    @results = []
  end

  def racers_unmatched
    @racers - @matches.map{|m| m.racers }.flatten
  end

  def autofill_matches
    self.racers_unmatched.each_slice(BIKES.length) { |a|
      @matches << (Race.new(a, @distance)) unless a.length == 1
    }
  end

  def record(race)
    #FIXME this method is too hilarious.
    @racers.delete(race.red_racer)
    @racers << race.red_racer
    @racers.delete(race.blue_racer)
    @racers << race.blue_racer
    matches.reject!{|m| m == race}
  end

  def add_racer(racer)
    return if @matches.find{|m| m.racers.include?(racer) } 
    unless (race=@matches.find{|m| m.racers.length < BIKES.length })
      race = Race.new([], @distance)
      @matches << race
    end
    race.add_racer(racer)
  end

  def best_time
    racers.map(&:best_time).max
  end

  def next_after(race)
    (matches-[race]).first
  end

end
