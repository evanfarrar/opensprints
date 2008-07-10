Infinty = 1/0.0
class Race
  attr_accessor :winner, :red_racer, :blue_racer
  def initialize(red_racer, blue_racer)
    red_racer.ticks.clear
    blue_racer.ticks.clear
    @red_racer = red_racer
    @blue_racer = blue_racer
  end
end
