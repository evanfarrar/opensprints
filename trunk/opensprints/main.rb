require 'rubygems'
require 'models/racer'
require 'builder'
require 'units/standard'
require 'controllers/dashboard_controller'
require 'rsvg2'
require 'gtk2'
require 'yaml'

options = YAML::load(File.read('conf.yml'))
require "sensors/#{options['sensor']['file']}_sensor"
SENSOR_LOCATION = options['sensor']['device']
RACE_DISTANCE = options['race_distance'].meters.to_km
RED_TRACK_LENGTH = 1315
BLUE_TRACK_LENGTH = 1200
RED_WHEEL_CIRCUMFERENCE = options['wheel_circumference']['red'].mm.to_km
BLUE_WHEEL_CIRCUMFERENCE = options['wheel_circumference']['blue'].mm.to_km
TITLE = options['title']


@w = Gtk::Window.new
@w.title = TITLE
@w.resize(993, 741)
box = Gtk::VBox.new(false, 0)
@dashboard_controller = DashboardController.new
rpb = RSVG::Handle.new_from_data('<svg></svg>')
@gi = Gtk::Image.new(rpb.pixbuf)
def start_race
  countdown = 5
  @gi.pixbuf=@dashboard_controller.count(countdown)
  @timeout = Gtk.timeout_add(1000) do
    case countdown
    when (1..10)
      @gi.pixbuf=@dashboard_controller.count(countdown)
      countdown-=1
      true
    when 0
      @dashboard_controller.begin_logging
      @timeout = Gtk.timeout_add(100) do
        @gi.pixbuf=@dashboard_controller.refresh
        continue = @dashboard_controller.continue?
        stop_race unless continue
        continue
      end
      false    
    end
  end
end
@w.signal_connect("destroy") do
  Gtk.main_quit
end
@w.signal_connect("key_press_event") do |window,event|
  if event.keyval == ?a
  #  stop_race
    start_race
  elsif event.keyval == ?z
    stop_race
  end
end
def stop_race
  Gtk.timeout_remove(@timeout) if @timeout
  @dashboard_controller.stop
end
box.pack_start(@gi)
@w << box
@w.show_all
Gtk.main
