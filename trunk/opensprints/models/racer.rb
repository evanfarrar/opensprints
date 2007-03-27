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

  def update(yaml)
    re = Regexp.new(@yaml_name)
    @ticks += yaml.select{|l|l =~ re} unless (yaml.length == 0)
    ticks_length = @ticks.length
    if ticks_length>1
      @distance = (@ticks.length)*(@wheel_circumference)
      last = YAML::load(@ticks[-2]||'')[@yaml_name]
      this = YAML::load(@ticks[-1]||'')[@yaml_name]
      @speed = rotation_elapsed_to_kmh(this-last)
    end
puts @ticks[-2..-1]
  end

  def set(yaml)
    re = Regexp.new(@yaml_name)
    @ticks = yaml.select{|l|l =~ re}
    ticks_length = @ticks.length
    if ticks_length>1
      @distance = (ticks_length)*(@wheel_circumference)
      last = YAML::load(@ticks[-2]||'')[@yaml_name]
      this = YAML::load(@ticks[-1]||'')[@yaml_name]
      @speed = rotation_elapsed_to_kmh(this-last)
    end
  end
private
  def rotation_elapsed_to_kmh(elapsed)
    ((@wheel_circumference/(elapsed))/(1.km))*1.hour.to_seconds
  end 
end
