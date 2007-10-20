require 'units/standard'
#require 'yaml'
class Racer
  attr_accessor :distance
  attr :wheel_circumference
  attr :yaml_name
  def initialize(attributes = {})
    @distance = 0
    @speed = 0
    @wheel_circumference = attributes[:wheel_circumference]||2097.mm.to_km
#    @yaml_name = attributes[:yaml_name]||(raise "yaml key neccessary")
    @ticks = []
  end

  def update(new_ticks)
    @ticks += new_ticks
    ticks_length = @ticks.length
    @distance = ((ticks_length)*(@wheel_circumference))
  end

  def tix
    @ticks.length
  end

private
  def rotation_elapsed_to_kmh(elapsed)
    ((@wheel_circumference/(elapsed))/(1.km))*1.hour.to_seconds
  end 
end
