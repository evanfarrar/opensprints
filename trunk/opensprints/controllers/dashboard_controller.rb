require 'gserver'
class Server < GServer
  def initialize(queue)
    super(5000)
    @queue = queue
    self.start
  end
  def serve( io )
    loop do
      puts line = io.readline 
      @queue << line
      @queue.inspect
    end
  end
end

class DashboardController
  def initialize
    style
    @dial_90_degrees = 8
    @dial_180_degrees = 24
    @dial_270_degrees = 40
    @red = Racer.new(:wheel_circumference => 2097.mm.to_km,
                     :track_length => 1315, :yaml_name => 'rider-one-tick')
    @blue = Racer.new(:wheel_circumference => 2097.mm.to_km,
                    :track_length => 1315, :yaml_name => 'rider-two-tick')
    @laps = 1
    @doc = build_template
    @svg = RSVG::Handle.new
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
    blue_log = @log.grep('rider-two-tick:')
    if blue_log
      @blue.update(blue_log.gsub(/rider-two-tick: /,''))
      track = BLUE_TRACK_LENGTH*@blue.distance
      @blue_dasharray = quadrantificate(700, BLUE_TRACK_LENGTH, rand(1315)).join(',')
      @blue_pointer_angle = speed_to_angle(rand(54))
    end
  end
  def read_red
    red_log = @log.grep('rider-one-tick:')
    if red_log
      @red.update(red_log.gsub(/rider-one-tick: /,''))
      track = RED_TRACK_LENGTH*@red.distance
      @red_dasharray = quadrantificate(765, RED_TRACK_LENGTH, track).join(',')
      @red_pointer_angle = speed_to_angle(@red.speed)
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
    @t = Thread.new do
        s = Server.new(@queue)
    end
puts @queue.inspect
  end

  def refresh
puts "bar"
return nil
    @log = nil
    @queue.length.times do
      @log << @queue.pop
    end
    if !@log==nil
      read_red
      read_blue
      if @blue.distance>1.0 or @red.distance>1.0
        winner = (@red.distance>@blue.distance) ? 'RED' : 'BLUE'
        svg = RSVG::Handle.new_from_data(@doc % ["#{winner} WINS!",@red_dasharray,
                @blue_dasharray, @blue_pointer_angle, @red_pointer_angle])
        @continue = false
      else
        svg = RSVG::Handle.new_from_data(@doc % ["IRO Sprint",@red_dasharray,
                        @blue_dasharray, @blue_pointer_angle, @red_pointer_angle])
        @continue = true
      end
      @pix = svg ? svg.pixbuf : nil
    end
    @pix#||RSVG::Handle.new_from_data(@doc % ["...",0,0,4,5,6])
  end
  def continue?
    @continue
  end
  def count(n)
    svg = RSVG::Handle.new_from_data(@doc % ["#{n}...",0,0,4,5,6])
    svg.pixbuf
  end
end
