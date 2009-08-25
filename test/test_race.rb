require 'lib/setup.rb'
require 'bacon'

describe 'A race' do
  before do
    @race = Race.new
  end

  it 'should be able to create race with racers' do
    racers = [Racer.new, Racer.new, Racer.new, Racer.new]
    r = Race.create(:race_participations => racers.map{|e| {:racer => e}})
    r.save
    r.racers.length.should==4
  end

  describe "racers" do
    it "should have a color" do
      racers = [Racer.new, Racer.new, Racer.new, Racer.new]
      r = Race.create(:race_participations => racers.map{|e| {:racer => e}})
      r.save
      r.race_participations.first.color.should== $BIKES.first
    end
  end

  it 'should have times' do
    racers = [Racer.new, Racer.new, Racer.new, Racer.new]
    r = Race.create(:race_participations => racers.map{|e| {:racer => e}})
    r.save
    r.race_participations.first.finish_time = 10.116
    r.save
    r.reload
    r.race_participations.first.finish_time.should==(10.116)
  end

  it 'should be finished if everyone has times.' do
    racers = [Racer.new, Racer.new, Racer.new, Racer.new]
    r = Race.create(:race_participations => racers.map{|e| {:racer => e}})
    r.save
    r.race_participations.first.finish_time = 10.116
    r.save
    r.reload
    r.finished?.should==(false)
    r.race_participations.each{|rp|rp.finish_time = 10.116}
    r.save
    r.reload
    r.finished?.should==(true)
  end

  describe 'winner' do
    it 'should be the lowest (fastest) time' do
      racers = [Racer.create(:name => "Steve"),
                Racer.create(:name => "Joe")]
      r = Race.create(:race_participations => racers.map{|e| {:racer => e}})
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
      r.raced?.should==(false) 
      r.raced = true
      r.raced?.should==(true) 
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
