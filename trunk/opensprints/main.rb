#require 'controllers/sprint_sensor'
require 'rubygems'
require 'models/racer'
require 'builder'
require 'units/standard'
require 'controllers/dashboard_controller'
require 'rsvg2'
require 'gtk2'

RACE_DISTANCE = 0.05.km
RED_TRACK_LENGTH = 1315
BLUE_TRACK_LENGTH = 1200
RED_WHEEL_CIRCUMFERENCE = 2097.mm.to_km
BLUE_WHEEL_CIRCUMFERENCE = 2097.mm.to_km

@w = Gtk::Window.new
@w.title = "IRO Sprints"
@w.resize(1024, 768)
box = Gtk::VBox.new(false, 0)
dashboard_controller = DashboardController.new
rpb = RSVG::Handle.new_from_data('<svg></svg>')
gi = Gtk::Image.new(rpb.pixbuf)
#rpb2 = RSVG::Handle.new_from_data(dashboard_controller.background)
#gi2 = Gtk::Image.new(rpb2.pixbuf.save('bg.png','png'))
countdown = 5
Gtk.timeout_add(1000) do
  case countdown
  when (1..10)
    gi.pixbuf=dashboard_controller.count(countdown)
    countdown-=1
    true
  when 0
    dashboard_controller.begin_logging('./sensor.rb')
    Gtk.timeout_add(100) do
      gi.pixbuf=dashboard_controller.refresh
      dashboard_controller.continue?
    end
    false    
  end
end
@w.signal_connect("destroy") do
  `killall -9 ruby`
  Gtk.main_quit
end
box.pack_start(gi)
@w << box
@w.show_all
Gtk.main
