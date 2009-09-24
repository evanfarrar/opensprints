class Tournament
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  has n, :races

  has n, :tournament_participations
  has n, :racers, :through => :tournament_participations, :mutable => true

  def racers
    tournament_participations.map(&:racer)
  end

  def autofill(racer_list=nil)
    racer_list ||= reload.unmatched_racers.to_a
    racer_list.each_slice($BIKES.length) { |a|
      races.create(:race_participations => a.map{|r| {:racer => r}})
    }
  end

  def unmatched_racers
    racers - matched_racers - tournament_participations.all(:eliminated => true).racers
  end

  def never_raced_and_not_eliminated
    matched = []
    races.each { |race|
      race.race_participations.each {|rp|
        matched << rp.racer
      }
    }
    racers - matched - tournament_participations.all(:eliminated => true).racers
  end

  def unregistered_racers
    Racer.all - racers
  end

  def matched_racers
    matched = []
    matches = self.races.select{|race| race.unraced? }
    matches.each { |race|
      race.race_participations.each {|rp|
        matched << rp.racer
      }
    }
    matched
  end
end
