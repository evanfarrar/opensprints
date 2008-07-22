class Race
  attr_accessor :red_racer, :blue_racer
  def initialize(red_racer, blue_racer, distance)
    red_racer.ticks = 0 if red_racer
    blue_racer.ticks = 0 if blue_racer
    @red_racer = red_racer
    @blue_racer = blue_racer
    @distance = distance
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

  def complete?
    self.racers.all? { |racer| racer.ticks >= @distance }
  end

  def winner
    standings = self.racers.sort_by { |racer| racer.tick_at(@distance) }

    winner = standings.first
    standings.reverse.each_with_index do |racer, i|
      racer.wins += i
      racer.races += 1
      racer.record_time(racer.tick_at(@distance))
    end
    winner
  end

  def flip
    @red_racer, @blue_racer = @blue_racer, @red_racer
  end
end
