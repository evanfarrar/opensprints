class Race
  attr_accessor :winner, :red_racer, :blue_racer
  def initialize(red_racer, blue_racer)
    red_racer.ticks.clear if red_racer
    blue_racer.ticks.clear if blue_racer
    @red_racer = red_racer
    @blue_racer = blue_racer
  end

  def racers
    [@red_racer,@blue_racer].compact
  end
  
  def add_racer(racer)
    racer.ticks.clear
    if red_racer
      @blue_racer = racer
    else
      @red_racer = racer
    end
  end

  def flip
    @red_racer, @blue_racer = @blue_racer, @red_racer
  end
end
