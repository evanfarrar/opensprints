require 'yaml'
require 'socket'
require 'time'
require 'lib/race_data'
require 'lib/sorty'
Infinity = 1/0.0
class Object
  def try(method, *args, &block)
    send(method, *args, &block)
  end
end

unless defined? Shoes
  lib_dir = nil
  homes = []
  homes << [ENV['HOME'], File.join( ENV['HOME'], '.shoes' )] if ENV['HOME']
  homes << [ENV['APPDATA'], File.join( ENV['APPDATA'], 'Shoes' )] if ENV['APPDATA']
  homes.each do |home_top, home_dir|
    next unless home_top
    if File.exists? home_top
      lib_dir = home_dir
      break
    end
  end
  LIB_DIR = lib_dir
end

begin
  options = YAML::load(File.read(File.join(LIB_DIR,'opensprints_conf.yml')))
rescue
  FileUtils.cp 'conf-sample.yml', File.join(LIB_DIR,'opensprints_conf.yml')
  options = YAML::load(File.read(File.join(LIB_DIR,'opensprints_conf.yml')))
end

$RACE_DISTANCE = options['race_distance'].to_f
$ROLLER_CIRCUMFERENCE = options['roller_circumference'].to_f
TITLE = options['title']
bikes = options['bikes']
bikes.delete('')
$BIKES = bikes
load "lib/sensors/#{options['sensor']['type']}_sensor.rb"
class MissingArduinoError < RuntimeError; end

begin
  SENSOR = Sensor.new(options['sensor']['device'])
rescue MissingArduinoError
  if defined? Shoes
    alert "The arduino could not be found at the configured address! Check your configuration."
  end
  load "lib/sensors/mock_sensor.rb"
end

HEIGHT = options['window_height'].to_i.nonzero?||600
WIDTH = options['window_width'].to_i.nonzero?||800

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
  require 'lib/config_controller'
  require 'lib/racer_controller'
  require 'lib/race_controller'
  require 'lib/category_controller'
  require 'lib/tournament_controller'
  require 'lib/interface_widgets'
else
  require 'rubygems'
end
require 'activesupport'
require 'dm-core'
require 'dm-aggregates'

DATABASE_PATH = File.join(LIB_DIR,'opensprints.db')
unless(File.exists? DATABASE_PATH)
  File.open(DATABASE_PATH , 'w+') {|file| nil }
  first_time = true
end
if(defined? Shoes)
  DataMapper.setup(:default, "sqlite3://#{DATABASE_PATH}")
else
  DataMapper.setup(:default, "sqlite3::memory:")
end
require 'lib/race_participation'
require 'lib/tournament_participation'
require 'lib/racer'
require 'lib/race'
require 'lib/categorization'
require 'lib/category'
require 'lib/tournament'
require "lib/race_windows/#{options['track']}"
if(first_time||!defined? Shoes)
  DataMapper.auto_migrate!
  #seed data
  Category.create(:name => "Women")
  Category.create(:name => "Men")
end
