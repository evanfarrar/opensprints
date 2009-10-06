class Tournament
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  has n, :obs_races

  has n, :tournament_participations
  has n, :obs_racers, :through => :tournament_participations, :mutable => true

  def racers
    tournament_participations.map(&:obs_racer)
  end

  def autofill(racer_list=nil)
    racer_list ||= reload.unmatched_racers.to_a
    racer_list.each_slice($BIKES.length) { |a|
      obs_races.create(:obs_race_participations => a.map{|r| {:obs_racer => r}})
    }
  end

  def unmatched_racers
    racers - matched_racers - tournament_participations.all(:eliminated => true).obs_racers
  end

  def never_raced_and_not_eliminated
    matched = []
    obs_races.each { |race|
      race.obs_race_participations.each {|rp|
        matched << rp.obs_racer
      }
    }
    racers - matched - tournament_participations.all(:eliminated => true).obs_racers
  end

  def unregistered_racers
    ObsRacer.all - racers
  end

  def matched_racers
    matched = []
    matches = self.obs_races.select{|race| race.unraced? }
    matches.each { |race|
      race.obs_race_participations.each {|rp|
        matched << rp.obs_racer
      }
    }
    matched
  end
end
