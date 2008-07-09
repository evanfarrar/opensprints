require 'enumerator'

class Tournament
  attr_accessor :racers
  attr_accessor :matches
  attr_accessor :results

  def initialize
    @racers = [ 'Evan', 'Ffonst', 'Alex', 'Luke', 'Oren', 'Katy', 'Jonathan' ]
    @racers.map!{|name| Racer.new(:name => name)}
    @matches = []
    @results = []
  end

  def racers_unmatched
    @racers - @matches.flatten
  end

  def autofill_matches
    self.racers_unmatched.each_slice(2) { |a|
      @matches << (a<<Race.new(*a)) unless a.length == 1
    }
  end

  def record(race)
    @racers.delete(race.red_racer)
    @racers << race.red_racer
    @racers.delete(race.blue_racer)
    @racers << race.blue_racer
    matches.reject!{|m| m[2] == race}
  end

  
end
