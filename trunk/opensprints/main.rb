base_dir = ENV['BASE_DIR']+'/'
errors = []
require 'yaml'

begin
  options = YAML::load(File.read('conf.yml'))
rescue
  errors<< "You must write a conf.yml. See samples conf-race.yml conf-debug.yml"
end
if errors.any?
  puts errors
  quit
end

require 'thread'
require base_dir+'lib/racer'
require base_dir+'lib/racer'
require base_dir+'lib/units/base'
require base_dir+'lib/units/standard'
require base_dir+'lib/secsy_time'
require base_dir+"lib/sensors/#{options['sensor']['file']}_sensor"
SENSOR_LOCATION = options['sensor']['device']
RACE_DISTANCE = options['race_distance'].meters.to_km
RED_WHEEL_CIRCUMFERENCE = options['wheel_circumference']['red'].mm.to_km
BLUE_WHEEL_CIRCUMFERENCE = options['wheel_circumference']['blue'].mm.to_km
TITLE = options['title']

Shoes.app :width => 800, :height => 600 do
  @red = Racer.new(:wheel_circumference => RED_WHEEL_CIRCUMFERENCE,
                   :name => "racer1")
  @blue = Racer.new(:wheel_circumference => BLUE_WHEEL_CIRCUMFERENCE,
                    :name => "racer2")
  bar_size = 800-2*60
  refresh = lambda do
    partial_log = []
    @queue.length.times do
      q = @queue.pop
      if q =~ /;/
        partial_log << q
      end
    end
    if (partial_log=partial_log.grep(/^[12]/)).any?
      if (blue_log = partial_log.grep(/^2/))
        @blue.update(blue_log)
      end
      if (red_log = partial_log.grep(/^1/))
        @red.update(red_log)
      end
      clear do
        fill black
        banner TITLE, :align => "center"
        stroke gray 0.5
        strokewidth 4
        line 60-4,280,60-4,380
        line 800-60+4,280,800-60+4,380
        blue_progress = bar_size*@blue.percent_complete
        stroke "#00F"
        fill "#FEE".."#32F", :angle => 90, :radius => 10
        rect 60, 300, blue_progress, 20 
        
        red_progress = bar_size*@red.percent_complete
        stroke "#F00"
        fill "#FEE".."#F23", :angle => 90, :radius => 10
        rect 60, 340, red_progress, 20 
        if @blue.distance>RACE_DISTANCE and @red.distance>RACE_DISTANCE
          winner = (@red.last_tick<@blue.last_tick) ? "RED" : "BLUE"
          title "#{winner} WINS!!!\n", :align => "center", 
                   :top => 380, :width => 800
          title "red: #{@red.last_tick}, blue: #{@blue.last_tick}",
                :align => 'center', :top => 450, :width => 800
          @sensor.stop
        end
      end    
    end
  end
  stack{
    fill black
    banner TITLE, :align => "center"
    @countdown = 5
    @start_time = Time.now+5
    @label = para "#{@countdown}..."
    animate(14) do
      @now = Time.now
      if @now < @start_time
        clear do
          banner "#{(@start_time-@now).round}..."
        end
      else
        unless @started
          @queue = Queue.new
          @sensor = Sensor.new(@queue, SENSOR_LOCATION)
          @sensor.start
          @started=true
        end
        refresh.call
      end
    end
  }
end
