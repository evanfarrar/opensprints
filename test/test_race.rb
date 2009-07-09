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

end
