require 'lib/setup.rb'
require 'bacon'

describe 'A tournament' do
  before do
    @tournament = Tournament.new
    $BIKES = ["red", "blue"]
  end

  it 'should have some racers' do
    3.times { @tournament.tournament_participations.build(:obs_racer => ObsRacer.new) }
    @tournament.racers.length.should==3
  end

  it 'should have some races' do
    @tournament.races = [Race.new, Race.new, Race.new]
    @tournament.races.length.should==3
  end

  it 'should have a name' do
    @tournament.name = "foo"
    @tournament.name.should == "foo"
  end

  it 'should know the unregistered racers' do
    ObsRacer.all.destroy!
    @tournament = Tournament.new
    6.times do
      @tournament.tournament_participations.build({:obs_racer => ObsRacer.create})
    end
    unregistered_racer = ObsRacer.create
    @tournament.unregistered_racers.should==([unregistered_racer])
  end

  describe 'unmatched_racers' do
    it 'should contain racers not in a match' do
      @tournament.save
      racers = ["Steve", "Joe"].map {|racer| ObsRacer.create(:name => racer) }
      racers.each {|racer|
        @tournament.tournament_participations.create({:obs_racer => racer})
      }
      @tournament.unmatched_racers.should ==(racers)
      sheila = ObsRacer.create(:name => "Sheila")
      @tournament.autofill
      @tournament.tournament_participations.create({:obs_racer => sheila})
      @tournament.unmatched_racers.should ==([sheila])
    end

    it 'should contain racers in a completed match.' do
      @tournament.save
      racers = ["Steve", "Joe"].map {|racer| ObsRacer.create(:name => racer) }
      racers.each {|racer|
        @tournament.tournament_participations.create({:obs_racer => racer})
      }
      @tournament.unmatched_racers.should ==(racers)
      sheila = ObsRacer.create(:name => "Sheila")
      @tournament.autofill
      @tournament.races.each{|r|r.update_attributes(:raced => true)}
      @tournament.tournament_participations.create({:obs_racer => sheila})
      @tournament.unmatched_racers.length.should==(3)
      
    end

    it 'should not contain eliminated racers' do
      @tournament.save
      racers = ["Steve", "Joe"].map {|racer| ObsRacer.create(:name => racer) }
      racers.each {|racer|
        @tournament.tournament_participations.create({:obs_racer => racer})
      }
      @tournament.unmatched_racers.should ==(racers)
      sheila = ObsRacer.create(:name => "Sheila")
      @tournament.autofill
      @tournament.races.each{|r|r.update_attributes(:raced => true)}
      @tournament.tournament_participations.each{|tp|tp.update_attributes(:eliminated => true)}
      @tournament.tournament_participations.create({:obs_racer => sheila})
      @tournament.unmatched_racers.should==([sheila])
    end
  end

  describe 'autofill' do
    it 'should result in all the racers being matched' do
      @tournament = Tournament.new
      6.times do
        @tournament.tournament_participations.build({:obs_racer => ObsRacer.create})
      end
      @tournament.save
      @tournament.reload
      @tournament.races.length.should == 0
      @tournament.autofill
      @tournament.races.length.should == 3
      @tournament.save
    end

    it 'should match only unmatched racers' do
      @tournament = Tournament.new
      6.times do
        @tournament.tournament_participations.build({:obs_racer => ObsRacer.create})
      end
      @tournament.save
      @tournament.reload
      @tournament.races.length.should == 0
      @tournament.autofill
      @tournament.races.length.should == 3
      @tournament.save
      6.times do
        @tournament.tournament_participations.build({:obs_racer => ObsRacer.create})
      end
      @tournament.save
      @tournament.reload
      @tournament.autofill
      @tournament.races.length.should == 6
    end

    it 'should make races with as many riders as there are bikes' do
      @tournament = Tournament.new
      $BIKES = ["red","blue","yellow"]
      6.times do
        @tournament.tournament_participations.build({:obs_racer => ObsRacer.create})
      end
      @tournament.save
      @tournament.reload
      @tournament.races.length.should == 0
      @tournament.autofill
      @tournament.races.length.should == 2
      @tournament.save
    end

    it 'should accept a list of racers' do
      @tournament = Tournament.new
      6.times do
        @tournament.tournament_participations.build({:obs_racer => ObsRacer.create})
      end
      @tournament.save
      @tournament.reload
      @tournament.races.length.should == 0
      @tournament.autofill(@tournament.tournament_participations.obs_racers[0..2])
      @tournament.races.length.should == 2
      @tournament.races.first.racers.length.should == 2
    end
  end
end
