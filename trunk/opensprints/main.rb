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

def cleanup
  system("ls log/|grep sensor_pid|cut -d. -f2 | xargs kill -9")
  system("rm log/sensor_pid*")
  system("echo ''>log/sensor.log")
end

def index
  #cleanup
  style
  @dial_90_degrees = 8
  @dial_180_degrees = 24
  @dial_270_degrees = 40
  @red = Racer.new(:wheel_circumference => 2097.mm.to_km,
                   :track_length => 1315, :yaml_name => 'rider-one-tick')
  @blue = Racer.new(:wheel_circumference => 2097.mm.to_km,
                    :track_length => 1315, :yaml_name => 'rider-two-tick')
  read_log
  read_red
  read_blue
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

@log = ''
def read_log
  @log_tmp = File.read('log/sensor.log',nil,@log.length){|f| f.readlines}
  @log << @log_tmp
end

def read_blue
  @blue.update(@log_tmp)
  track = BLUE_TRACK_LENGTH*@blue.distance
  @blue_dasharray = quadrantificate(700, BLUE_TRACK_LENGTH, track).join(',')
  @blue_pointer_angle = speed_to_angle(@blue.speed)
end

def read_red
  @red.update(@log_tmp)
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
#Gdk::Input.add(File.open('log/sensor.log'),Gdk::Input::WRITE) do
#  read_log
#  read_red
#  read_blue
#  moz.render_data(doc % [@red_dasharray, @blue_dasharray, @blue_pointer_angle, @red_pointer_angle],"http://foo","application/xml")
#end
@w.signal_connect("destroy") do
#  cleanup
  Gtk.main_quit
end
doc.gsub!(/%([^s])/,'%%\1')
button1 = Gtk::Button.new('Move World')
button1.signal_connect("clicked") do
  read_log
  read_red
  read_blue
  moz.render_data(doc % [@red_dasharray, @blue_dasharray, @blue_pointer_angle, @red_pointer_angle],"http://foo","application/xml")
end
box.pack_start(moz)
box.pack_start(button1,false,false)
@w << box
@w.show_all
moz.render_data(doc % [@red_dasharray, @blue_dasharray, @blue_pointer_angle, @red_pointer_angle],"http://foo","application/xml")
system('ruby sensor.rb > log/sensor.log &')
Gtk.main
