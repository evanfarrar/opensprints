require 'yaml'
require 'socket'
require 'time'
require 'lib/race_data'
require 'lib/sorty'

begin
  options = YAML::load(File.read('conf.yml'))
rescue
  FileUtils.cp 'conf-sample.yml', 'conf.yml'
  options = YAML::load(File.read('conf.yml'))
end

$RACE_DISTANCE = options['race_distance'].to_f
$ROLLER_CIRCUMFERENCE = options['roller_circumference'].to_f  # in METERS DAMNIT!
TITLE = options['title']
bikes = options['bikes']
bikes.delete('')
BIKES = bikes
require 'lib/racer'
require 'lib/race'
require 'lib/interface_widgets'
require 'lib/tournament'
load "lib/sensors/#{options['sensor']['type']}_sensor.rb"
require "lib/race_windows/#{options['track']}"
class MissingArduinoError < RuntimeError; end

begin
  SENSOR = Sensor.new(options['sensor']['device'])
rescue MissingArduinoError
  alert "The arduino could not be found at the configured address! Check your configuration."
  load "lib/sensors/mock_sensor.rb"
  load "lib/config_app.rb"
end

HEIGHT = options['window_height']||600
WIDTH = options['window_width']||800


if options['background']
  if File.readable?(options['background'])
    BACKGROUND = options['background']
  else
    BACKGROUND = Shoes.instance_eval(options['background'])
  end
else
  BACKGROUND = Shoes::COLORS[:black]
end


UNIT_SYSTEM = (options['units'] == 'standard') ? :mph : :kph
UNIT_SYSTEM_STR = (options['units'] == 'standard') ? "mph" :
"km/h"

module Enumerable
  def second
    self[1]
  end

  def third
    self[2]
  end

  def fourth
    self[3]
  end
end

class Numeric
  def to_minutes_seconds_string
    [self/60 % 60, self % 60].map{|t| t.to_s.rjust(2,'0')}.join(':')
  end
end

module Subclasses
  # return a list of the subclasses of a class
  def subclasses(direct = false)
    classes = []
    if direct
      ObjectSpace.each_object(Class) do |c|
        next unless c.superclass == self
        classes << c
      end
    else
      ObjectSpace.each_object(Class) do |c|
        next unless c.ancestors.include?(self) and (c != self)
        classes << c
      end
    end
    classes
  end
end

Object.send(:include, Subclasses)

class Shoes::ColoredProgressBar < Shoes::Widget
  def initialize(percent,top,color)
    stroke color
    fill color
    rect 6, top, percent, 20
  end
end

Shoes.setup do
  gem "activesupport"
end
require 'activesupport'
