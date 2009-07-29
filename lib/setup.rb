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
load "lib/sensors/#{options['sensor']['type']}_sensor.rb"
class MissingArduinoError < RuntimeError; end

begin
  SENSOR = Sensor.new(options['sensor']['device'])
rescue MissingArduinoError
  if defined? Shoes
    alert "The arduino could not be found at the configured address! Check your configuration."
    load "lib/config_app.rb"
  end
  load "lib/sensors/mock_sensor.rb"
end

HEIGHT = options['window_height']||600
WIDTH = options['window_width']||800

if defined? Shoes
  if options['background']
    if File.readable?(options['background'])
      BACKGROUND = options['background']
    else
      BACKGROUND = Shoes.instance_eval(options['background'])
    end
  else
    BACKGROUND = Shoes::COLORS[:black]
  end
end


UNIT_SYSTEM = (options['units'] == 'standard') ? :mph : :kph
UNIT_SYSTEM_STR = (options['units'] == 'standard') ? "mph" :
"km/h"

require 'lib/ruby_extensions.rb'

if defined? Shoes
  class Shoes::ColoredProgressBar < Shoes::Widget
    def initialize(percent,top,color)
      stroke color
      fill color
      rect 6, top, percent, 20
    end
  end
end

if defined? Shoes
  Shoes.setup do
    gem "activesupport"
    gem "bacon"
    gem "dm-core"
    gem "do_sqlite3"
  end
  require 'lib/racer_controller'
  require 'lib/category_controller'
  require 'lib/tournament_controller'
else
  require 'rubygems'
end
require 'activesupport'
require 'dm-core'
DataMapper.setup(:default, 'sqlite3::memory:')
require 'lib/race_participation'
require 'lib/tournament_participation'
require 'lib/racer'
require 'lib/race'
require 'lib/categorization'
require 'lib/category'
require 'lib/interface_widgets' if defined? Shoes
require 'lib/tournament'
require "lib/race_windows/#{options['track']}"
DataMapper.auto_migrate!
