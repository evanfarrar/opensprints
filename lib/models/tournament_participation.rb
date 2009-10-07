class TournamentParticipation < Sequel::Model
  many_to_one :racer
  many_to_one :tournament

  def best_time
    best = DB[:race_participations].filter(:racer_id => racer.id).join(:races, :tournament_id => tournament.id).order(:finish_time).select(:finish_time).first

    best[:finish_time] if best
  end

  def rank
    standings = self.tournament.tournament_participations.sort_by{|tp|tp.best_time||Infinity}
    standings.index(self)+1
  end

  def losses
    RaceParticipation.filter(:racer_id => racer.id).join(:races, :tournament_id => tournament.id).group(:id).all.select{|rp|rp.race.winner.racer.pk != self.racer.pk}.length
  end

  def eliminate
    self.update(:eliminated => true)
  end

  def race_participations
    RaceParticipation.filter(:racer_id => racer.id).join(:races, :tournament_id => tournament.id).group(:id).all
  end

end
