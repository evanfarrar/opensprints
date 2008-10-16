Infinity = 1/0.0
class Racer
  attr_accessor :distance, :best_time, :wins, :races, :finish_time
  attr :roller_circumference
  attr :name
  attr :yaml_name
  attr_accessor :ticks
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

  def record_time(time)
    @best_time = [@best_time, time].min
  end

  def losses
    @races - @wins 
  end

end
