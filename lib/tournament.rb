require 'enumerator'

class Tournament
  attr_accessor :racers
  attr_accessor :matches
  attr_accessor :results

  def initialize
    @racers = [ 'Evan', 'Ffonst', 'Alex', 'Luke', 'Oren', 'Katy', 'Jonathan' ]
    @racers.map!{|name| Racer.new(:name => name)}
    @matches = []
  end

  def racers_unmatched
    @racers - @matches.flatten
  end

  def autofill_matches
    self.racers_unmatched.each_slice(2) { |a|
      @matches << a unless a.length == 1
    }
  end

  
end
