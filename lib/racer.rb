Infinity = 1/0.0
class Racer
  attr_accessor :distance, :best_time, :wins, :races, :finish_time, :speed, :text
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
    @best_time = Infinity
    @wins = 0
    @races = 0
    @speed = 0
    raise unless $ROLLER_CIRCUMFERENCE
    @roller_circumference = $ROLLER_CIRCUMFERENCE
    @ticks = 0
    @name = attributes[:name]
    @race_distance = attributes[:race_distance]
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
