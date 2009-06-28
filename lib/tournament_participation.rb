class TournamentParticipation
  include DataMapper::Resource
  property :id, Serial

  belongs_to :racer
  belongs_to :tournament
end
