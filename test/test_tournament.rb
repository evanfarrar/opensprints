require 'lib/setup.rb'
require 'bacon'

describe 'A tournament' do
  before do
    @tournament = Tournament.new
  end

  it 'should have some racers' do
    @tournament.racers = [Racer.new, Racer.new, Racer.new]
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

end
