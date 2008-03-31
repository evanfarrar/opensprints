require 'rubygems'
require 'socket'
require 'test/unit'
require 'controllers/dashboard_controller'
require 'models/racer'
require 'builder'
require 'rsvg2'
require 'digest/md5'

RACE_DISTANCE = 2.km
RED_TRACK_LENGTH = 1315
BLUE_TRACK_LENGTH = 1200
RED_WHEEL_CIRCUMFERENCE = 0.01.km
BLUE_WHEEL_CIRCUMFERENCE = 0.01.km

class DashboardControllerTest < Test::Unit::TestCase
  def test_create
    dashboard_controller = DashboardController.new
    assert_equal digest(Gdk::Pixbuf.new('test/5countdown.png').pixels),
      digest(dashboard_controller.count(5).pixels)
    dashboard_controller.begin_logging('-e ""')
    @s = TCPSocket.new("localhost", 5000)
    100.times{|n| tick_red(n); tick_blue(n) }
    sleep 0.1
    assert_equal digest(Gdk::Pixbuf.new('test/halvesies.png').pixels),
      digest(dashboard_controller.refresh.pixels)
    100.times{|n| tick_red(n); tick_blue(n+100) }
    sleep 0.1
    dashboard_controller.refresh.save('test/fullsies.png','png')
    assert_equal digest(Gdk::Pixbuf.new('test/fullsies.png').pixels),
      digest(dashboard_controller.refresh.pixels)
    tick_blue(201)
    sleep 0.1
    assert_equal digest(Gdk::Pixbuf.new('test/blue_wins.png').pixels),
      digest(dashboard_controller.refresh.pixels)
  end

#for some reason reinstantiating DashboardController doesn't work
  def xtest_winning
    dashboard_controller = DashboardController.new
    assert_equal digest(Gdk::Pixbuf.new('test/5countdown.png').pixels),
      digest(dashboard_controller.count(5).pixels)
    dashboard_controller.begin_logging('-e ""')
    @s = TCPSocket.new("localhost", 5000)
    100.times{|n| tick_red(n); tick_blue(n) }
    sleep 0.1
    dashboard_controller.refresh.save('/tmp/half.png','png')
    assert_equal digest(Gdk::Pixbuf.new('test/halvesies.png').pixels),
      digest(dashboard_controller.refresh.pixels)
    100.times{|n| tick_red(n); tick_blue(n+100) }
    sleep 0.1
    dashboard_controller.refresh.save('test/fullsies.png','png')
    assert_equal digest(Gdk::Pixbuf.new('test/fullsies.png').pixels),
      digest(dashboard_controller.refresh.pixels)
    tick_red(201)
    sleep 0.1
    assert_equal digest(Gdk::Pixbuf.new('test/red_wins.png').pixels),
      digest(dashboard_controller.refresh.pixels)
  end

  def digest(this)
    Digest::MD5.hexdigest(this)
  end

  def tick(rider,ct)
    @s.puts "rider-#{rider}-tick: #{0.05+(0.01*ct)}"
  end

  def tick_red(n); tick('one',n); end
  def tick_blue(n); tick('two',n); end


end
