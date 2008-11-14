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
            Thread.current["red"] = @r.redTickData            
            Thread.current["blue"] = @r.blueTickData
            Thread.current["green"] = @r.greenTickData            
            Thread.current["yellow"] = @r.yellowTickData
            #Thread.current["red_finish"] = l.gsub(/1f: /,'').to_i
            #Thread.current["blue_finish"] = l.gsub(/2f: /,'').to_i          
        end
        puts l
      end
    end
    self
  end

  def values
    {:red => @t["red"], :blue => @t["blue"], :green => @t["green"], :yellow => @t["yellow"],
     :red_finish => @t["red_finish"], :blue_finish => @t["blue_finish"], :green_finish => @t["green_finish"], :yellow_finish => @t["yellow_finish"]}
  end

  def stop
    @f.puts 's'
    @f.flush
    @t.kill
  end
end
