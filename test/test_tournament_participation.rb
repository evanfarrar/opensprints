require 'lib/setup.rb'
require 'bacon'

describe 'A tournament participation' do
  before do
    @tournament = Tournament.create(:name => "December")
    @racer = Racer.create(:name => "winston")
    @tournament_participation = TournamentParticipation.create(:racer => @racer, :tournament => @tournament)
    [4.2, 5.3, 3.0, 6.1].each do |time|
      r = Race.create(:tournament => @tournament)
      r.race_participations.create(:racer => @racer, :finish_time => time)
    end
  end

  
  it 'should have a best time' do
    @tournament_participation.best_time.should==(3.0)
  end

  it 'should not have a best time if the racer has not raced' do
    @racer2 = Racer.create(:name => "winston")
    @tournament_participation = TournamentParticipation.create(:racer => @racer2, :tournament => @tournament)
    @tournament_participation.best_time.should==(nil)
  end

  it 'should have a relative rank'


end
