#Arduino: a sensor written for the arduino open source hardware.
class Sensor
  attr_accessor :r
  def initialize(filename=nil)
    raise "Can't access the arduino! Ensure that it is plugged in and that the proper device is specified in your config." unless File.writable?(filename)
    #HACK oogity boogity magic happens here:
	if RUBY_PLATFORM.index("darwin") > -1
		@f = File.open(filename, 'w+')
		`stty -f #{filename} cs8 115200 ignbrk -brkint -icrnl -imaxbel -opost -onlcr -isig -icanon -iexten -echo -echoe -echok -echoctl -echoke -noflsh -ixon -crtscts`
	else
		`stty -F #{filename} cs8 115200 ignbrk -brkint -icrnl -imaxbel -opost -onlcr -isig -icanon -iexten -echo -echoe -echok -echoctl -echoke -noflsh -ixon -crtscts`
		@f = File.open(filename, 'w+')
	end
  end

  def start
    @r = RaceData.new()
    @t.kill if @t
    @t = Thread.new do
      @f.putc 'g'
      @f.flush
      while true do
        l = @f.readline
        if l=~/!.*/
          @r.parseStringToRaceData(l)
          Thread.current["racers"] = @r.racers
          Thread.current["time"] = @r.time
        end
        puts l
      end
    end
    self
  end

  # I don't like this but it's just legacy until 
  # I truly deprecate the basic_msg
  def finish_times
    @t["racers"].map{|r| r[$RACE_DISTANCE / $ROLLER_CIRCUMFERENCE] }
  end

  def racers
    @t["racers"]
  end

  def time
    @t["time"]
  end

  def stop
    @f.puts 's'
    @f.flush
    @t.kill
  end
end
