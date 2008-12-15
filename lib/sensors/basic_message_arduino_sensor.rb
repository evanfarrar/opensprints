#Arduino: a sensor written for the arduino open source hardware.
class Sensor
  attr_accessor :queue
  def initialize(filename=nil)
    raise 'File Not Writable!' unless File.writable?(filename)
    #HACK oogity boogity magic happens here:
    `stty -F #{filename} cs8 115200 ignbrk -brkint -icrnl -imaxbel -opost -onlcr -isig -icanon -iexten -echo -echoe -echok -echoctl -echoke -noflsh -ixon -crtscts`
    @f = File.open(filename, 'w+')
  end

  def start
    @t.kill if @t
    @t = Thread.new do
      @f.putc 'g'
      Thread.current["racers"] = [[],[],[],[]]
      Thread.current["finish_times"] = []
      @f.flush
      while true do
        l = @f.readline
        if l=~/:/
          if l =~ /1:/
            Thread.current["racers"][0] =  [Thread.current["blue_finish"]||1] * l.gsub(/1: /,'').to_i
          end
          if l =~ /2:/
            Thread.current["racers"][1] =  [Thread.current["red_finish"]||2] * l.gsub(/2: /,'').to_i
          end
          if l =~ /1f:/
            Thread.current["finish_times"][0] = l.gsub(/1f: /,'').to_i
          end
          if l =~ /2f:/
            Thread.current["finish_times"][1] = l.gsub(/2f: /,'').to_i
          end
          if l =~ /3f:/
            Thread.current["finish_times"][2] = l.gsub(/3f: /,'').to_i
          end
          if l =~ /4f:/
            Thread.current["finish_times"][3] = l.gsub(/4f: /,'').to_i
          end
          if l =~ /t:/
            Thread.current["time"] = l.gsub(/t: /,'').to_i
          end
        end
        puts l
      end
    end
    self
  end

  def finish_times
    @t['finish_times'] || []
  end

  def values
    {:red => @t["red"], :blue => @t["blue"],
     :red_finish => @t["red_finish"], :blue_finish => @t["blue_finish"]}
  end

  def racers
    @t['racers'] || [[],[],[],[]]
  end

  def time
    @t['time'] || 0
  end

  def stop
    @f.puts 's'
    @f.flush
    @t.kill
  end
end
