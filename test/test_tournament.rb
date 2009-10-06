require 'lib/setup.rb'
require 'bacon'

describe 'An obsolete tournament' do
  before do
    @tournament = ObsTournament.new
    $BIKES = ["red", "blue"]
  end

  it 'should have some racers' do
    3.times { @tournament.obs_tournament_participations.build(:obs_racer => ObsRacer.new) }
    @tournament.racers.length.should==3
  end

  it 'should have some races' do
    @tournament.obs_races = [ObsRace.new, ObsRace.new, ObsRace.new]
    @tournament.obs_races.length.should==3
  end

  it 'should have a name' do
    @tournament.name = "foo"
    @tournament.name.should == "foo"
  end

  it 'should know the unregistered racers' do
    ObsRacer.all.destroy!
    @tournament = ObsTournament.new
    6.times do
      @tournament.obs_tournament_participations.build({:obs_racer => ObsRacer.create})
    end
    unregistered_racer = ObsRacer.create
    @tournament.unregistered_racers.should==([unregistered_racer])
  end

  describe 'unmatched_racers' do
    it 'should contain racers not in a match' do
      @tournament.save
      racers = ["Steve", "Joe"].map {|racer| ObsRacer.create(:name => racer) }
      racers.each {|racer|
        @tournament.obs_tournament_participations.create({:obs_racer => racer})
      }
      @tournament.unmatched_racers.should ==(racers)
      sheila = ObsRacer.create(:name => "Sheila")
      @tournament.autofill
      @tournament.obs_tournament_participations.create({:obs_racer => sheila})
      @tournament.unmatched_racers.should ==([sheila])
    end

    it 'should contain racers in a completed match.' do
      @tournament.save
      racers = ["Steve", "Joe"].map {|racer| ObsRacer.create(:name => racer) }
      racers.each {|racer|
        @tournament.obs_tournament_participations.create({:obs_racer => racer})
      }
      @tournament.unmatched_racers.should ==(racers)
      sheila = ObsRacer.create(:name => "Sheila")
      @tournament.autofill
      @tournament.obs_races.each{|r|r.update_attributes(:raced => true)}
      @tournament.obs_tournament_participations.create({:obs_racer => sheila})
      @tournament.unmatched_racers.length.should==(3)
      
    end

    it 'should not contain eliminated racers' do
      @tournament.save
      racers = ["Steve", "Joe"].map {|racer| ObsRacer.create(:name => racer) }
      racers.each {|racer|
        @tournament.obs_tournament_participations.create({:obs_racer => racer})
      }
      @tournament.unmatched_racers.should ==(racers)
      sheila = ObsRacer.create(:name => "Sheila")
      @tournament.autofill
      @tournament.obs_races.each{|r|r.update_attributes(:raced => true)}
      @tournament.obs_tournament_participations.each{|tp|tp.update_attributes(:eliminated => true)}
      @tournament.obs_tournament_participations.create({:obs_racer => sheila})
      @tournament.unmatched_racers.should==([sheila])
    end
  end

  describe 'autofill' do
    it 'should result in all the racers being matched' do
      @tournament = ObsTournament.new
      6.times do
        @tournament.obs_tournament_participations.build({:obs_racer => ObsRacer.create})
      end
      @tournament.save
      @tournament.reload
      @tournament.obs_races.length.should == 0
      @tournament.autofill
      @tournament.obs_races.length.should == 3
      @tournament.save
    end

    it 'should match only unmatched racers' do
      @tournament = ObsTournament.new
      6.times do
        @tournament.obs_tournament_participations.build({:obs_racer => ObsRacer.create})
      end
      @tournament.save
      @tournament.reload
      @tournament.obs_races.length.should == 0
      @tournament.autofill
      @tournament.obs_races.length.should == 3
      @tournament.save
      6.times do
        @tournament.obs_tournament_participations.build({:obs_racer => ObsRacer.create})
      end
      @tournament.save
      @tournament.reload
      @tournament.autofill
      @tournament.obs_races.length.should == 6
    end

    it 'should make races with as many riders as there are bikes' do
      @tournament = ObsTournament.new
      $BIKES = ["red","blue","yellow"]
      6.times do
        @tournament.obs_tournament_participations.build({:obs_racer => ObsRacer.create})
      end
      @tournament.save
      @tournament.reload
      @tournament.obs_races.length.should == 0
      @tournament.autofill
      @tournament.obs_races.length.should == 2
      @tournament.save
    end

    it 'should accept a list of racers' do
      @tournament = ObsTournament.new
      6.times do
        @tournament.obs_tournament_participations.build({:obs_racer => ObsRacer.create})
      end
      @tournament.save
      @tournament.reload
      @tournament.obs_races.length.should == 0
      @tournament.autofill(@tournament.obs_tournament_participations.obs_racers[0..2])
      @tournament.obs_races.length.should == 2
      @tournament.obs_races.first.racers.length.should == 2
    end
  end
end

describe 'A tournament' do
  before do
    @tournament = Tournament.create
    $BIKES = ["red", "blue"]
  end

  it 'should have some racers' do
    3.times do
      racer = Racer.create
      tp = TournamentParticipation.create(:racer => racer,
        :tournament => @tournament)
    end
    @tournament.racers.length.should==3
  end

  it 'should have some races' do
    3.times do
      Race.create(:tournament => @tournament)
    end
    @tournament.races.length.should==3
  end

  it 'should have a name' do
    @tournament.name = "foo"
    @tournament.name.should == "foo"
  end

  it 'should know the unregistered racers' do
    Racer.all.each{|r|r.destroy}
    @tournament = Tournament.create
    6.times do
      TournamentParticipation.create(:racer => Racer.create,
        :tournament => @tournament)
    end
    unregistered_racer = Racer.create
    @tournament.unregistered_racers.should==([unregistered_racer])
  end

  describe 'unmatched_racers' do
    it 'should contain racers not in a match' do
      @tournament.save
      racers = ["Steve", "Joe"].map {|racer| Racer.create(:name => racer) }
      racers.each {|racer|
        TournamentParticipation.create(:racer => racer,
          :tournament => @tournament)
      }
      @tournament.unmatched_racers.should ==(racers)
      sheila = Racer.create(:name => "Sheila")
      @tournament.autofill
      TournamentParticipation.create(:racer => sheila,
        :tournament => @tournament)
      @tournament.reload.unmatched_racers.should ==([sheila])
    end

    it 'should contain racers in a completed match.' do
      @tournament.save
      racers = ["Steve", "Joe"].map {|racer| Racer.create(:name => racer) }
      racers.each {|racer|
        TournamentParticipation.create(:racer => racer,
          :tournament => @tournament)
      }
      @tournament.unmatched_racers.should ==(racers)
      sheila = Racer.create(:name => "Sheila")
      @tournament.autofill
      @tournament.races.each{|r|r.raced = true; r.save}
      TournamentParticipation.create(:racer => sheila,
        :tournament => @tournament)
      @tournament.reload.unmatched_racers.length.should==(3)
    end

    it 'should not contain eliminated racers' do
      @tournament.save
      racers = ["Steve", "Joe"].map {|racer| Racer.create(:name => racer) }
      racers.each {|racer|
        TournamentParticipation.create(:racer => racer,
          :tournament => @tournament)
      }
      @tournament.unmatched_racers.should ==(racers)

      sheila = Racer.create(:name => "Sheila")
      @tournament.autofill
      @tournament.races.each{|r|r.raced = true; r.save}
      @tournament.tournament_participations.each{|tp|tp.eliminated = true; tp.save}
      TournamentParticipation.create(:racer => sheila,
        :tournament => @tournament)
      @tournament.reload.unmatched_racers.should==([sheila])
    end
  end

  describe 'autofill' do
    it 'should result in all the racers being matched' do
      @tournament = ObsTournament.new
      6.times do
        @tournament.obs_tournament_participations.build({:obs_racer => ObsRacer.create})
      end
      @tournament.save
      @tournament.reload
      @tournament.obs_races.length.should == 0
      @tournament.autofill
      @tournament.obs_races.length.should == 3
      @tournament.save
    end

    it 'should match only unmatched racers' do
      @tournament = ObsTournament.new
      6.times do
        @tournament.obs_tournament_participations.build({:obs_racer => ObsRacer.create})
      end
      @tournament.save
      @tournament.reload
      @tournament.obs_races.length.should == 0
      @tournament.autofill
      @tournament.obs_races.length.should == 3
      @tournament.save
      6.times do
        @tournament.obs_tournament_participations.build({:obs_racer => ObsRacer.create})
      end
      @tournament.save
      @tournament.reload
      @tournament.autofill
      @tournament.obs_races.length.should == 6
    end

    it 'should make races with as many riders as there are bikes' do
      @tournament = ObsTournament.new
      $BIKES = ["red","blue","yellow"]
      6.times do
        @tournament.obs_tournament_participations.build({:obs_racer => ObsRacer.create})
      end
      @tournament.save
      @tournament.reload
      @tournament.obs_races.length.should == 0
      @tournament.autofill
      @tournament.obs_races.length.should == 2
      @tournament.save
    end

    it 'should accept a list of racers' do
      @tournament = ObsTournament.new
      6.times do
        @tournament.obs_tournament_participations.build({:obs_racer => ObsRacer.create})
      end
      @tournament.save
      @tournament.reload
      @tournament.obs_races.length.should == 0
      @tournament.autofill(@tournament.obs_tournament_participations.obs_racers[0..2])
      @tournament.obs_races.length.should == 2
      @tournament.obs_races.first.racers.length.should == 2
    end
  end
end
