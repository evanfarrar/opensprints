class Tournament < Sequel::Model
  one_to_many :tournament_participations
  many_to_many :racers, :join_table => :tournament_participations
  one_to_many :races

  #TODO: optimize
  def unregistered_racers
    Racer.all - self.racers
  end

  def autofill(racer_list=nil)
    racer_list ||= reload.unmatched_racers.to_a
    racer_list.each_slice($BIKES.length) { |a|
      race = Race.create(:tournament => self)
      a.map{|r| RaceParticipation.create(:racer => r, :race => race)}
    }
  end

  def unmatched_racers
    racers - matched_racers - tournament_participations.select{|tp|tp.eliminated}.map{|tp|tp.racer}
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

  #TODO: test
  def never_raced_and_not_eliminated
    matched = []
    races.each { |race|
      race.race_participations.each {|rp|
        matched << rp.racer
      }
    }
    racers - matched - tournament_participations.select{|tp|tp.eliminated}.map{|tp|tp.racer}
  end



end
