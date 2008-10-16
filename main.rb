#!/usr/bin/env shoes
require 'yaml'
require 'RaceData'

begin
  options = YAML::load(File.read('conf.yml'))
rescue
  alert "You must write a conf.yml. See sample in conf-sample.yml"
end

RACE_DISTANCE = options['race_distance']
$ROLLER_CIRCUMFERENCE = options['roller_circumference']  # in METERS DAMNIT!
TITLE = options['title']
require 'lib/racer'
require 'lib/race'
require 'lib/interface_widgets'
require 'lib/tournament'
require "lib/sensors/#{options['sensor']['type']}_sensor"
require 'lib/race_presenter'

queue = Queue.new
SENSOR = Sensor.new(queue, options['sensor']['device'])

UNIT_SYSTEM = (options['units'] == 'standard') ? :mph : :kmph

Shoes.app :title => TITLE, :width => 800, :height => 600 do
  extend RacePresenterMod
  @tournament = Tournament.new(RACE_DISTANCE)

  match = Race.new(Racer.new(:name => ask("red?"), :units => UNIT_SYSTEM),
    Racer.new(:name => ask("blue?"), :units => UNIT_SYSTEM), RACE_DISTANCE)
  race_window(match, RACE_DISTANCE, SENSOR, TITLE)
end
