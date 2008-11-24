#Arduino: a sensor written for the arduino open source hardware.
class Sensor
  attr_accessor :queue, :r
  def initialize(queue, filename=nil)
    @queue = queue
    raise 'File Not Writable!' unless File.writable?(filename)
    #HACK oogity boogity magic happens here:
    `stty -F #{filename} cs8 115200 ignbrk -brkint -icrnl -imaxbel -opost -onlcr -isig -icanon -iexten -echo -echoe -echok -echoctl -echoke -noflsh -ixon -crtscts`
    @f = File.open(filename, 'w+')
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
