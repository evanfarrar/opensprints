require 'yaml'
require 'lib/race_data'

begin
  options = YAML::load(File.read('conf.yml'))
rescue
  `cp conf-sample.yml conf.yml`
  options = YAML::load(File.read('conf.yml'))
end

RACE_DISTANCE = options['race_distance']
$ROLLER_CIRCUMFERENCE = options['roller_circumference']  # in METERS DAMNIT!
TITLE = options['title']
bikes = options['bikes']
bikes.delete('')
BIKES = bikes
require 'lib/racer'
require 'lib/race'
require 'lib/interface_widgets'
require 'lib/tournament'
require "lib/sensors/#{options['sensor']['type']}_sensor"

SENSOR = Sensor.new(options['sensor']['device'])

UNIT_SYSTEM = (options['units'] == 'standard') ? :mph : :kmph

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

class Shoes::ColoredProgressBar < Shoes::Widget
  def initialize(percent,top,color)
    stroke color
    fill color
    rect 6, top, percent, 20
  end
end
