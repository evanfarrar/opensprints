require 'yaml'
begin
  options = YAML::load(File.read('conf.yml'))
rescue
  puts "You must write a conf.yml. See samples conf-race.yml conf-debug.yml"
  quit
end

require 'thread'
require Dir.pwd+'/lib/racer'
Kernel::require Dir.pwd+'/lib/serialport.so'
require Dir.pwd+'/lib/units/standard'
require Dir.pwd+'/lib/secsy_time'
require Dir.pwd+"/lib/sensors/#{options['sensor']['file']}_sensor"
SENSOR_LOCATION = options['sensor']['device']
RACE_DISTANCE = options['race_distance'].meters.to_km
RED_WHEEL_CIRCUMFERENCE = options['wheel_circumference']['red'].mm.to_km
BLUE_WHEEL_CIRCUMFERENCE = options['wheel_circumference']['blue'].mm.to_km
TITLE = options['title']

@red = Racer.new(:wheel_circumference => RED_WHEEL_CIRCUMFERENCE,
                 :name => "racer1")
@blue = Racer.new(:wheel_circumference => BLUE_WHEEL_CIRCUMFERENCE,
                  :name => "racer2")
@queue = Queue.new
@sensor = Sensor.new(@queue, SENSOR_LOCATION)
@sensor.start
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
    blue_progress = bar_size*@blue.percent_complete      
    red_progress = bar_size*@red.percent_complete
    puts "red: #{@red.percent_complete*100}%, blue: #{@blue.percent_complete*100}%"
    if @blue.distance>RACE_DISTANCE and @red.distance>RACE_DISTANCE
      winner = (@red.last_tick<@blue.last_tick) ? "RED" : "BLUE"
      puts "#{winner} WINS!!!\n"
      puts "red: #{@red.last_tick}, blue: #{@blue.last_tick}"
      @sensor.stop
    end
  end
end
loop do
   refresh.call
#   puts "Hey Jess, this should not be blocked" if Time.now.to_i % 4 == 0
end
