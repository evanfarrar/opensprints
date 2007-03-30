require 'units/standard'
require 'yaml'
class Racer
  attr_accessor :distance
  attr_accessor :speed
  attr :wheel_circumference
  attr :yaml_name
  def initialize(attributes = {})
    @distance = 0
    @speed = 0
    @wheel_circumference = attributes[:wheel_circumference]||2097.mm.to_km
    @yaml_name = attributes[:yaml_name]||(raise "yaml key neccessary")
    @ticks = []
  end

  def update(new_ticks)
    @ticks += new_ticks
    ticks_length = @ticks.length
    if ticks_length>1
                                  #this are just some magic values...
      @distance = ((@ticks.length)*(@wheel_circumference)*5)*2.5
      last = @ticks[-2]
      this = @ticks[-1]
      @speed = rotation_elapsed_to_kmh(this-last)
    end
  end

private
  def rotation_elapsed_to_kmh(elapsed)
    ((@wheel_circumference/(elapsed))/(1.km))*1.hour.to_seconds
  end 
end
