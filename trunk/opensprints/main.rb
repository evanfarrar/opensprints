require 'sprint_sensor'
require 'rubygems'
require 'models/racer'
require 'builder'
require 'gtkmozembed'
require 'units/standard'

xml_data = ''
RED_TRACK_LENGTH = 1315
BLUE_TRACK_LENGTH = 1200
RED_WHEEL_CIRCUMFERENCE = 2097.mm.to_km
BLUE_WHEEL_CIRCUMFERENCE = 2097.mm.to_km

def index
  style
  @dial_90_degrees = 8
  @dial_180_degrees = 24
  @dial_270_degrees = 40
  @red = Racer.new(:wheel_circumference => 2097.mm.to_km,
                   :track_length => 1315, :yaml_name => 'rider-one-tick')
  @blue = Racer.new(:wheel_circumference => 2097.mm.to_km,
                    :track_length => 1315, :yaml_name => 'rider-two-tick')
  @laps = 1
end

def quadrantificate(offset, total, distance=0)
  if distance > offset
    [0,0,offset,((total-offset)-(distance-offset))]
  else
    [0,(offset-distance),distance,(total-offset)]
  end
end

def speed_to_angle(speed)
  unadjusted = ((speed/48.0)*270.0+45.0)
  unadjusted-180
end

def read_blue
  @blue.update(@sensor.read_blue)
  track = BLUE_TRACK_LENGTH*@blue.distance
  @blue_dasharray = quadrantificate(700, BLUE_TRACK_LENGTH, track).join(',')
  @blue_pointer_angle = speed_to_angle(@blue.speed)
end

def read_red
  @red.update(@sensor.read_red)
  track = RED_TRACK_LENGTH*@red.distance
  @red_dasharray = quadrantificate(765, RED_TRACK_LENGTH, track).join(',')
  @red_pointer_angle = speed_to_angle(@red.speed)
end

def style
  File.open('views/style.css') do |f|
    @stylishness = f.readlines.join
  end
end

index
xml = Builder::XmlMarkup.new(:target => xml_data)
svg = ''
File.open('views/svg.rb') do |f|
  svg = f.readlines.join
end
eval svg
doc = ''
File.open('views/wrap.html') do |f|
  doc = f.readlines.join
end 
doc = doc % xml_data

@w = Gtk::Window.new
@w.title = ""
@w.resize(1024, 768)
box = Gtk::VBox.new(false, 0)
moz = Gtk::MozEmbed.new
moz.chrome_mask = Gtk::MozEmbed::ALLCHROME
countdown = 5
Gtk.timeout_add(1000) do
  case countdown
  when (1..5)
    moz.render_data("<h1>#{countdown}....</h1>","http://foo","text/html")
    countdown-=1
    true
  when 0
    @sensor = SprintSensor.new
    Gtk.timeout_add(500) do
      read_red
      read_blue
      if @blue.distance>1.0 or @red.distance>1.0
        winner = (@red.distance>@blue.distance) ? 'RED' : 'BLUE'
        moz.render_data("<h1>#{winner} WINS!</h1>","http://foo","text/html")
        false
      else
        moz.render_data(doc % [@red_dasharray, @blue_dasharray, @blue_pointer_angle, @red_pointer_angle],"http://foo","application/xml")
        true
      end
    end
    false    
  end
end
@w.signal_connect("destroy") do
  Gtk.main_quit
end
doc.gsub!(/%([^s])/,'%%\1')
button1 = Gtk::Button.new('Move World')
button1.signal_connect("clicked") do
  read_red
  read_blue
  moz.render_data(doc % [@red_dasharray, @blue_dasharray, @blue_pointer_angle, @red_pointer_angle],"http://foo","application/xml")
end
box.pack_start(moz)
box.pack_start(button1,false,false)
@w << box
@w.show_all
#moz.render_data(doc % [@red_dasharray, @blue_dasharray, @blue_pointer_angle, @red_pointer_angle],"http://foo","application/xml")
Gtk.main
