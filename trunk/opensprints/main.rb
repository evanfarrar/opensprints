require 'rubygems'
require 'models/racer'
require 'builder'
require 'units/standard'
require 'controllers/dashboard_controller'
require 'rsvg2'
require 'gtk2'

RACE_DISTANCE = 0.200.km
RED_TRACK_LENGTH = 1315
BLUE_TRACK_LENGTH = 1200
RED_WHEEL_CIRCUMFERENCE = 85.mm.to_km
BLUE_WHEEL_CIRCUMFERENCE = 85.mm.to_km

@w = Gtk::Window.new
@w.title = "IRO Sprints"
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
        @dashboard_controller.continue?
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
    stop_race
    start_race
  elsif event.keyval == ?z
    stop_race
  end
end
def stop_race
  Gtk.timeout_remove(@timeout) if @timeout
  @dashboard_controller.t.kill if @dashboard_controller.t
end
box.pack_start(@gi)
@w << box
@w.show_all
Gtk.main
