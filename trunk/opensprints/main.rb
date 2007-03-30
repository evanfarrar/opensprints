require 'controllers/sprint_sensor'
require 'rubygems'
require 'models/racer'
require 'builder'
require 'gtkmozembed'
require 'units/standard'
require 'controllers/dashboard_controller'

RED_TRACK_LENGTH = 1315
BLUE_TRACK_LENGTH = 1200
RED_WHEEL_CIRCUMFERENCE = 2097.mm.to_km
BLUE_WHEEL_CIRCUMFERENCE = 2097.mm.to_km

dashboard_controller = DashboardController.new
@w = Gtk::Window.new
@w.title = "IRO Sprints"
@w.resize(760, 570)
box = Gtk::VBox.new(false, 0)
moz = Gtk::MozEmbed.new
moz.chrome_mask = Gtk::MozEmbed::ALLCHROME
countdown = 5
Gtk.timeout_add(1000) do
  case countdown
  when (1..5)
    moz.render_data(dashboard_controller.count(countdown),
                      "http://foo","text/html")
    countdown-=1
    true
  when 0
    dashboard_controller.begin_logging
    Gtk.timeout_add(500) do
      moz.render_data(*(dashboard_controller.refresh))
      dashboard_controller.continue?
    end
    false    
  end
end
@w.signal_connect("destroy") do
  Gtk.main_quit
end
box.pack_start(moz)
@w << box
@w.show_all
Gtk.main
