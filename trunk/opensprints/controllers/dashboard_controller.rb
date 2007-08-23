require 'thread'
class DashboardController
  def initialize
    style
    @dial_90_degrees = 8
    @dial_180_degrees = 24
    @dial_270_degrees = 40
    @red = Racer.new(:wheel_circumference => RED_WHEEL_CIRCUMFERENCE,
                     :track_length => 1315, :yaml_name => '1')
    @blue = Racer.new(:wheel_circumference => BLUE_WHEEL_CIRCUMFERENCE,
                    :track_length => 1315, :yaml_name => '2')
    @laps = 1
    @continue = true
    @doc = build_template
    @svg = RSVG::Handle.new
  end
  def quadrantificate(offset, total, distance=0)
    distance*=1/RACE_DISTANCE
    if distance > offset
      [0,0,offset,((total-offset)-(distance-offset))]
    else
      [0,(offset-distance),distance,(total-offset)]
    end
  end
  def read_blue
    blue_log = @partial_log.grep(/2/)
    if blue_log
#      blue_log.map!{ |a| a.gsub(/rider-two-tick: /,'').to_f }
      @blue.update(blue_log)
      track = BLUE_TRACK_LENGTH*@blue.distance
      @blue_dasharray = quadrantificate(700, BLUE_TRACK_LENGTH, track).join(',')
    end
  end
  def read_red
    red_log = @partial_log.grep(/1/)
    if red_log
#      red_log.map!{ |a| a.gsub(/rider-one-tick: /,'').to_f }
      @red.update(red_log)
      track = RED_TRACK_LENGTH*@red.distance
      @red_dasharray = quadrantificate(765, RED_TRACK_LENGTH, track).join(',')
    end
  end
  def style
    File.open('views/style.css') do |f|
      @stylishness = f.readlines.join
    end
  end

  def build_template
    xml_data = ''
    xml = Builder::XmlMarkup.new(:target => xml_data)
    svg = ''
    File.open('views/svg.rb') do |f|
      svg = f.readlines.join
    end
    eval svg
    xml_data.gsub!(/%([^s])/,'%%\1')
  end
  def t
    @t
  end
  def begin_logging
    @queue = Queue.new
    @t.kill if @t
    @t = Thread.new do
      f = File.open('/dev/ttyACM0')
  
      while true do
        l = f.readline
        @queue << l
        puts l
      end
    end
  end

  def refresh
    @partial_log = []
    @queue.length.times do
      @partial_log << @queue.pop
    end
    if @partial_log.any?
      read_red
      read_blue
      if @blue.distance>RACE_DISTANCE or @red.distance>RACE_DISTANCE
        winner = (@red.distance>@blue.distance) ? 'RED' : 'BLUE'
        svg = RSVG::Handle.new_from_data(@doc % ["#{winner} WINS!!!",0,0,4,5,6])
        @continue = false
      else
        svg = RSVG::Handle.new_from_data(@doc % ["IRO Sprint",@red_dasharray,
                        @blue_dasharray])
        @continue = true
      end
      @pix = svg ? svg.pixbuf : nil
    end
    @pix||RSVG::Handle.new_from_data(@doc % ["0...",0,0,4,5,6]).pixbuf
  end
  def continue?
    @continue
  end
  def count(n)
    svg = RSVG::Handle.new_from_data(@doc % ["#{n}...",0,0,4,5,6])
    svg.pixbuf
  end

  def background
    xml_data = ''
    xml = Builder::XmlMarkup.new(:target => xml_data)
    svg = ''
    File.open('views/background.rb') do |f|
      svg = f.readlines.join
    end
    eval svg
    xml_data
  end
end
