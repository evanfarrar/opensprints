require 'lib/setup.rb'
require 'bacon'

describe 'A race participation' do
  before do
    @r = RaceParticipation.new
  end

  it 'should have a temporary place for keeping track of ticks' do
    @r.ticks = 12
    @r.ticks.should==(12)
  end

  it 'should have a distance' do
    $ROLLER_CIRCUMFERENCE = 0.5
    @r.ticks = 42
    @r.distance.should==(21.0)
  end

  describe 'percent complete' do
    it 'should be the ratio of race distance to distance' do
      $RACE_DISTANCE = 84.0
      $ROLLER_CIRCUMFERENCE = 0.5
      @r.ticks = 42
      @r.percent_complete.should==(0.25)
      @r.ticks = 0
      @r.percent_complete.should==(0.0)
      @r.ticks = 1200.0
      @r.percent_complete.should==(1.0)
    end
  end
end
