class Racer
  attr_accessor :distance
  attr :wheel_circumference
  attr :name
  attr :yaml_name
  attr :ticks
  include Comparable
  def <=>(other_racer)
    self.name<=>other_racer.name
  end

  def initialize(attributes = {})
    @distance = 0
    @speed = 0
    raise unless $ROLLER_CIRCUMFERENCE
    @wheel_circumference = $ROLLER_CIRCUMFERENCE
    @ticks = []
    @name = attributes[:name]
    @race_distance = attributes[:race_distance]
    if attributes[:units] == :standard
      alias :rotation_elapsed_to_speed :rotation_elapsed_to_mph
    else
      alias :rotation_elapsed_to_speed :rotation_elapsed_to_kmh
    end
  end

  def update(new_ticks)
    @ticks += new_ticks.map{|t| SecsyTime.parse(t.split(/;/)[1]).in_seconds}
    ticks_length = @ticks.length
    @distance = ((ticks_length)*(@wheel_circumference))
  end

  def tix
    @ticks.length
  end

  def speed
    unless @speed == 1/0.0
      @speed
    else
      0
    end
  end

  def tick_at(distance)
    @ticks[distance / @wheel_circumference]
  end
private
  def rotation_elapsed_to_mph(elapsed)
    ((@wheel_circumference/(elapsed))/(1.0.mile))*1.hour.to_seconds
  end 
  def rotation_elapsed_to_kmh(elapsed)
    ((@wheel_circumference/(elapsed))/(1.0.km))*1.hour.to_seconds
  end 
end
