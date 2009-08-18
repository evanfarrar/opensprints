class TournamentParticipation
  include DataMapper::Resource
  property :id, Serial

  belongs_to :racer
  belongs_to :tournament

  def best_time
    RaceParticipation.first("race.tournament_id" => tournament.id,
                            :racer_id => racer.id,
                            :order => [:finish_time.asc]
    ).try(:finish_time)
  end
end
