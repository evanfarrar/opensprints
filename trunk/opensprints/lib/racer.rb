class Racer
  attr_accessor :distance
  attr :wheel_circumference
  attr :name
  attr :yaml_name
  attr :ticks
  def initialize(attributes = {})
    @distance = 0
    @speed = 0
    @wheel_circumference = attributes[:wheel_circumference]
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

  def percent_complete
    [1.0, @distance/@race_distance.to_f].min
  end

  def first_tick
    @ticks.first
  end
  def last_tick
    @ticks[@race_distance / @wheel_circumference]
  end
private
  def rotation_elapsed_to_mph(elapsed)
    ((@wheel_circumference/(elapsed))/(1.0.mile))*1.hour.to_seconds
  end 
  def rotation_elapsed_to_kmh(elapsed)
    ((@wheel_circumference/(elapsed))/(1.0.km))*1.hour.to_seconds
  end 
end
