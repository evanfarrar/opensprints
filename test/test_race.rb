require 'lib/setup.rb'
require 'bacon'

describe 'An obsolete race' do
  before do
    @race = ObsRace.new
  end

  it 'should be able to create race with racers' do
    racers = [ObsRacer.new, ObsRacer.new, ObsRacer.new, ObsRacer.new]
    r = ObsRace.create(:obs_race_participations => racers.map{|e| {:obs_racer => e}})
    r.save
    r.racers.length.should==4
  end

  describe "racers" do
    it "should have a color" do
      racers = [ObsRacer.new, ObsRacer.new, ObsRacer.new, ObsRacer.new]
      r = ObsRace.create(:obs_race_participations => racers.map{|e| {:obs_racer => e}})
      r.save
      r.obs_race_participations.first.color.should== $BIKES.first
    end
  end

  it 'should have times' do
    racers = [ObsRacer.new, ObsRacer.new, ObsRacer.new, ObsRacer.new]
    r = ObsRace.create(:obs_race_participations => racers.map{|e| {:obs_racer => e}})
    r.save
    r.obs_race_participations.first.finish_time = 10.116
    r.save
    r.reload
    r.obs_race_participations.first.finish_time.should==(10.116)
  end

  it 'should be finished if everyone has times.' do
    racers = [ObsRacer.new, ObsRacer.new, ObsRacer.new, ObsRacer.new]
    r = ObsRace.create(:obs_race_participations => racers.map{|e| {:obs_racer => e}})
    r.save
    r.obs_race_participations.first.finish_time = 10.116
    r.save
    r.reload
    r.finished?.should==(false)
    r.obs_race_participations.each{|rp|rp.finish_time = 10.116}
    r.save
    r.reload
    r.finished?.should==(true)
  end

  describe 'winner' do
    it 'should be the lowest (fastest) time' do
      racers = [ObsRacer.create(:name => "Steve"),
                ObsRacer.create(:name => "Joe")]
      r = ObsRace.create(:obs_race_participations => racers.map{|e| {:obs_racer => e}})
      r.save
      r.obs_race_participations.first.finish_time = 10.116
      r.save
      r.reload
      r.winner.obs_racer.name.should==("Steve")
    end
  end

  describe 'raced' do
    it 'should track whether or not the race has been run' do
      r = ObsRace.create
      r.raced?.should==(false) 
      r.raced = true
      r.raced?.should==(true) 
    end

    it 'should have a converse: unraced?' do
      r = ObsRace.create
      r.unraced?.should==(true) 
      r.raced = true
      r.unraced?.should==(false) 
    end
  end

  describe 'next race' do
    it 'should be the next one after this one' do
      t = ObsTournament.create
      r1 = ObsRace.create(:obs_tournament => t)
      r2 = ObsRace.create(:obs_tournament => t)
      r1.next_race.should==(r2)
    end

    it 'should only show the next unraced race' do
      t = ObsTournament.create
      r1 = ObsRace.create(:obs_tournament => t)
      r2 = ObsRace.create(:obs_tournament => t, :raced => true)
      r3 = ObsRace.create(:obs_tournament => t)
      r1.next_race.should==(r3)
    end
  end

  it "should match up names and versus to colors" do
    $BIKES = ["fuschia", "pink", "maroon", "blue"]
    racers = [ObsRacer.create(:name => "Alice"),
              ObsRacer.create(:name => "Bob"),
              ObsRacer.create(:name => "Cathy"),
              ObsRacer.create(:name => "Dale")]
    r = ObsRace.create(:obs_race_participations => [{:obs_racer => racers[0]}])
    r.names_to_colors.should==([["Alice","fuschia"]])

    r = ObsRace.create(:obs_race_participations => racers[0..1].map{|e|{:obs_racer => e}})
    r.names_to_colors.should==([["Alice","fuschia"],
                                ["vs.","white"],
                                ["Bob","pink"]])

    r = ObsRace.create(:obs_race_participations => racers[0..2].map{|e|{:obs_racer => e}})
    r.names_to_colors.should==([["Alice","fuschia"],
                                ["vs.","white"],
                                ["Bob","pink"],
                                ["vs.","white"],
                                ["Cathy","maroon"]])

    r = ObsRace.create(:obs_race_participations => racers[0..3].map{|e|{:obs_racer => e}})
    r.names_to_colors.should==([["Alice","fuschia"],
                                ["vs.","white"],
                                ["Bob","pink"],
                                ["vs.","white"],
                                ["Cathy","maroon"],
                                ["vs.","white"],
                                ["Dale","blue"]])
  end
end

describe 'A race' do
  before do
    @race = Race.new
  end

  it 'should be able to create race with racers' do
    racers = [Racer.create, Racer.create, Racer.create, Racer.create]
    r = Race.create
    racers.map{|e| RaceParticipation.create(:racer => e, :race => r)}
    r.save
    Race[r.pk].racers.length.should==4
  end

  describe "racers" do
    it "should have a color" do
      racers = [Racer.create, Racer.create, Racer.create, Racer.create]
      r = Race.create
      racers.map{|e| RaceParticipation.create(:racer => e, :race => r)}
      r.save
      r.race_participations.first.color.should== $BIKES.first
    end
  end

  it 'should have times' do
    racers = [Racer.create, Racer.create, Racer.create, Racer.create]
    r = Race.create
    racers.map{|e| RaceParticipation.create(:racer => e, :race => r)}
    r.save
    r.race_participations.first.finish_time = 10.116
    r.race_participations.first.save
    r.reload
    r.race_participations.first.finish_time.should==(10.116)
  end

  it 'should be finished if everyone has times.' do
    racers = [Racer.create, Racer.create, Racer.create, Racer.create]
    r = Race.create
    racers.map{|e| RaceParticipation.create(:racer => e, :race => r)}
    r.save
    r.race_participations.first.finish_time = 10.116
    r.race_participations.first.save
    r.reload
    r.finished?.should==(false)
    r.race_participations.each{|rp|rp.finish_time = 10.116; rp.save}
    r.reload
    r.finished?.should==(true)
  end

  describe 'winner' do
    it 'should be the lowest (fastest) time' do
      racers = [Racer.create(:name => "Steve"),
                Racer.create(:name => "Joe")]
      r = Race.create
      racers.each{|racer| RaceParticipation.create(:racer => racer,:race => r)} 
      r.save
      r.race_participations.first.finish_time = 10.116
      r.save
      r.reload
      r.winner.racer.name.should==("Steve")
    end
  end
  describe 'raced' do
    it 'should track whether or not the race has been run' do
      r = Race.create
      r.raced.should==(false) 
      r.raced = true
      r.raced.should==(true) 
    end

    it 'should have a converse: unraced?' do
      r = Race.create
      r.unraced?.should==(true) 
      r.raced = true
      r.unraced?.should==(false) 
    end
  end

  describe 'next race' do
    it 'should be the next one after this one' do
      t = Tournament.create
      r1 = Race.create(:tournament => t)
      r2 = Race.create(:tournament => t)
      r1.next_race.should==(r2)
    end

    it 'should only show the next unraced race' do
      t = Tournament.create
      r1 = Race.create(:tournament => t)
      r2 = Race.create(:tournament => t, :raced => true)
      r3 = Race.create(:tournament => t)
      r1.next_race.should==(r3)
    end
  end

end
