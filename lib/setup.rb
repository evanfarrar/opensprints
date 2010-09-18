require 'yaml'
require 'ostruct'
require 'socket'
require 'time'
require 'lib/race_data'
require 'ftools'
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
SKIN = options['skin'] if File.exist?('media/skins/'+options['skin'].to_s)
if defined? SKIN and defined? Shoes
  load("media/skins/#{SKIN}/stylesheet.rb") if File.exist?("media/skins/#{SKIN}/stylesheet.rb")
  class Main < Shoes
    include CustomStyles if(defined?(CustomStyles))
  end
end
RACE_TRACK = (["progress_bars", "clock"].detect { |track| track == options['track'] } || "progress_bars").to_sym

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

if RUBY_PLATFORM =~ /linux/
  width,height = `xrandr | grep '*'`.split[0].split('x')
else
  width,height = 800,600
end

USABLE_HEIGHT = options['usable_window_height'].to_i.nonzero?||nil
height = options['window_height'].to_i.nonzero?||(height.to_i-100)
HEIGHT = [height,550].max
WIDTH = options['window_width'].to_i.nonzero?||(width.to_i-50)

if defined? Shoes
  class String
    def is_shoes_color?
      if self =~ /rgb/
        true
      elsif self =~ /^"#....../
        true
      elsif self.any? && Shoes::COLORS.keys.include?(self.to_sym)
        true
      else
        false
      end
    end
  end
  if options['background_color'] && options['background_color'].is_shoes_color?
    BACKGROUND_COLOR = Shoes.instance_eval(options['background_color'])
  else
    BACKGROUND_COLOR = Shoes::COLORS[:black]
  end

  if options['background_image'] && File.readable?(options['background_image'])
    BACKGROUND_IMAGE = options['background_image']
  else
    BACKGROUND_IMAGE = rgb(0,0,0,0)
  end
  if options['menu_background_image'] && File.readable?(options['menu_background_image'])
    MENU_BACKGROUND_IMAGE = options['menu_background_image']
  else
    MENU_BACKGROUND_IMAGE = rgb(0,0,0,0)
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
  Dir.glob('media/fonts/*').each do |f|
    font(f)
  end

  Dir.glob('lib/controllers/*_controller.rb').each do |controller|
    require controller
  end
  require 'lib/interface_widgets'
else
  require 'rubygems'
  require 'bundler/setup'
end
require 'hpricot'
require 'active_support'
require 'sequel'
require 'sequel/extensions/migration'
require 'sequel/extensions/schema_dumper'
require 'sqlite3'
require 'net/http/post/multipart'
require 'r18n-desktop'
$i18n = R18n.from_env('lib/translations',options['locale'])

DATABASE_PATH = File.join(LIB_DIR,'opensprints_data.db')
unless(File.exists? DATABASE_PATH)
  File.open(DATABASE_PATH , 'w+') {|file| nil }
  first_time = true
end
require "opensprints-core"
if(first_time||!defined? Shoes)
  #seed data
  Category.create(:name => "Women")
  Category.create(:name => "Men")
end
