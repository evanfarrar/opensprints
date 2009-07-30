require 'lib/setup.rb'
require 'bacon'

describe 'A race' do
  before do
    @race = Race.new
  end

  it 'should have some racers' do
    @race.racers = [Racer.new, Racer.new, Racer.new]
    @race.racers.length.should==3
  end

  it 'should be able to create race with racers' do
    racers = [Racer.new, Racer.new, Racer.new, Racer.new]
    r = Race.create(:race_participations => racers.map{|e| {:racer => e}})
    r.save
    r.racers.length.should==4
  end

end
