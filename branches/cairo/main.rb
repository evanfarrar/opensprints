errors = []
errors += ((['rubygems','builder','units/standard','gtk2','cairo',
        'yaml'].map do |gem_name|
  begin
    require gem_name
    nil
  rescue LoadError
    "#{gem_name} is not installed"
  end
end).compact)

begin
  options = YAML::load(File.read('conf.yml'))
rescue
  errors<< "You must write a conf.yml. See samples conf-race.yml conf-debug.yml"
end
if errors.any?
  puts errors
  exit
end

require 'lib/dashboard_controller'
require 'lib/racer'
require 'lib/secsy_time'
require "lib/sensors/#{options['sensor']['file']}_sensor"
SENSOR_LOCATION = options['sensor']['device']
RACE_DISTANCE = options['race_distance'].meters.to_km
GRAPH_MAX = (options['graph_max']||60).to_f
RED_TRACK_LENGTH = 1315
BLUE_TRACK_LENGTH = 1200
RED_WHEEL_CIRCUMFERENCE = options['roller_circumference']['red'].mm.to_km
BLUE_WHEEL_CIRCUMFERENCE = options['roller_circumference']['blue'].mm.to_km
TITLE = options['title']
if options['units'] == 'standard'
  UNIT_SYSTEM = :mph
else    
  UNIT_SYSTEM = :kmph
end
  


@w = Gtk::Window.new
@w.title = TITLE
@w.resize(800, 600)
box = Gtk::VBox.new(false, 0)


@drawing_area = Gtk::DrawingArea.new

foo = lambda do
  @gc = Gdk::GC.new(@drawing_area.window)
  @pixmap = Gdk::Pixmap.new(nil, 993, 741, 24)
  context = @pixmap.create_cairo_context
  @dashboard_controller = DashboardController.new(context,ARGV[0]||'red',ARGV[1]||'blue',UNIT_SYSTEM||:kmph)
  @drawing_area.window.draw_drawable(@gc, @pixmap, 0, 0, 0, 0, -1, -1)
end
@drawing_area.signal_connect("realize", &foo)
@drawing_area.signal_connect("expose_event") do
  @dashboard_controller.refresh if @dashboard_controller.continue?
  @drawing_area.window.draw_drawable(@gc, @pixmap, 0, 0, 0, 0, -1, -1)
end
def start_race
  countdown = 5
  @timeout = Gtk.timeout_add(1000) do
    case countdown
    when (1..5)
      @drawing_area.queue_draw
      @dashboard_controller.countdown("#{countdown}...")
      puts countdown
      countdown-=1
      true
    when 0
      @dashboard_controller.countdown('Go!')
      @dashboard_controller.start
      @timeout = Gtk.timeout_add(50) do
        @drawing_area.queue_draw
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
box.pack_start(@drawing_area)
@w << box
@w.show_all
Gtk.main
