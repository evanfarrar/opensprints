require 'yaml'
require 'lib/race_data'

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
require 'lib/shoe_locker'
require "lib/sensors/#{options['sensor']['type']}_sensor"

SENSOR = Sensor.new(options['sensor']['device'])

UNIT_SYSTEM = (options['units'] == 'standard') ? :mph : :kmph
