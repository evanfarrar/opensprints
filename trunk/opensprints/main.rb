puts ((['rubygems','builder','units/standard','rsvg2','gtk2','cairo',
      'gnomecanvas2','yaml'].map do |gem_name|
  begin
    require gem_name
    nil
  rescue LoadError
    "#{gem_name} is not installed"
  end
end).compact)

require 'lib/dashboard_controller'
require 'lib/racer'

options = YAML::load(File.read('conf.yml'))
require "lib/sensors/#{options['sensor']['file']}_sensor"
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
#rpb = RSVG::Handle.new_from_data('<svg></svg>')
#@gi = Gtk::Image.new(rpb.pixbuf)


@drawing_area = Gtk::DrawingArea.new

foo = lambda do
  @gc = Gdk::GC.new(@drawing_area.window)
  @pixmap = Gdk::Pixmap.new(nil, 993, 741, 24)
  context = @pixmap.create_cairo_context
  @dashboard_controller = DashboardController.new(context)
  @drawing_area.window.draw_drawable(@gc, @pixmap, 0, 0, 0, 0, -1, -1)
end
bar = foo
@foo = 5
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
      puts countdown
      countdown-=1
      true
    when 0
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
