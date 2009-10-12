require 'lib/setup.rb'
require 'bacon'

describe 'A tournament participation' do
  before do
    @tournament = Tournament.create(:name => "December")
    @racer = Racer.create(:name => "winston")
    @tournament_participation = TournamentParticipation.create(:racer => @racer, :tournament => @tournament)
    [4.2, 5.3, 3.0, 6.1].each do |time|
      r = Race.create(:tournament => @tournament,:raced => true)
      RaceParticipation.create(:racer => @racer, :race => r, 
        :finish_time => time)
    end

    @racer2 = Racer.create(:name => "winston")
    @tournament_participation2 = TournamentParticipation.create(:racer => @racer2, :tournament => @tournament)

    @racer3 = Racer.create(:name => "winston")
    @tournament_participation3 = TournamentParticipation.create(:racer => @racer3, :tournament => @tournament)
    r = Race.create(:tournament => @tournament, :raced => true)
    unraced_race = Race.create(:tournament => @tournament,:raced => false)
    RaceParticipation.create(:racer => @racer3, :race => r, 
      :finish_time => 10.0)
    RaceParticipation.create(:racer => @racer, :race => r, 
      :finish_time => 5.0)
    RaceParticipation.create(:racer => @racer, :race => unraced_race)
    RaceParticipation.create(:racer => @racer2, :race => unraced_race, 
      :finish_time => nil)
  end

  
  it 'should have a best time' do
    @tournament_participation.best_time.should==(3.0)
  end
  it 'should not have a best time if the racer has not raced' do
    @tournament_participation2.best_time.should==(nil)
  end

  it 'should have a relative rank' do
    @tournament_participation.rank.should==(1)
    @tournament_participation2.rank.should==(3)
    @tournament_participation3.rank.should==(2)
  end

  it 'should have a number of losses for eliminaton' do
    @tournament_participation.losses.should==(0)
    @tournament_participation2.losses.should==(0)
    @tournament_participation3.losses.should==(1)
  end

end
