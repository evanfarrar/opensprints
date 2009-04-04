Infinity = 1/0.0
class Racer
  attr_accessor :distance, :best_time, :wins, :races, :finish_time, :text, :color
  attr :roller_circumference
  attr :name
  attr :yaml_name
  attr_accessor :ticks
  alias :to_s :name

  include Comparable
  def <=>(other_racer)
    self.name<=>other_racer.name
  end

  def initialize(attributes = {})
    @distance = 0
    @distance_old = 0
    @time = 0
    @time_old = 0
    @best_time = Infinity
    @wins = 0
    @races = 0
    @speed = 0
    raise unless $ROLLER_CIRCUMFERENCE
    @roller_circumference = $ROLLER_CIRCUMFERENCE
    @ticks = 0
    @name = attributes[:name]
    @color = attributes[:color]
    @race_distance = attributes[:race_distance]
  end

  def distance
    self.ticks * @roller_circumference
  end

  def speed(time)
    @distance = self.distance
    @time = time
    if(@time_old > @time)
      @time_old = time
    end
    if time == 0
      0
    else
      if(@time-@time_old > 999)
        if(@distance_old > 0)
          @speed = "%.2f" % (((@distance - @distance_old) / (@time - @time_old)) * 2236.93629).to_f
        else
          @speed = 0
        end
        @distance_old = @distance
        @time_old = @time
      end
      @speed
    end
  end

  def finish_time=(finish_time)
    record_time(finish_time/1000.0) if finish_time
    @finish_time = finish_time
  end

  def record_time(time)
    @best_time = [@best_time, time].min
  end

  def losses
    @races - @wins
  end

end
