#Arduino: a sensor written for the arduino open source hardware.
class Sensor
  attr_accessor :queue
  def initialize(filename=nil)
    @f = TCPSocket.new("127.0.0.1", 5331)
  end

  def start
    @t.kill if @t
    Thread.abort_on_exception = true
    @t = Thread.new do
      @f.putc 'g'
      Thread.current["racers"] = [[],[],[],[]]
      Thread.current["finish_times"] = []
      @f.flush
      while true do
        l = c = ''
        until c == "\000"
          begin
            c = @f.read_nonblock(1)
            print c
            l << c
          rescue
            puts "waiting..."
          end
        end
        l.gsub!(/\000/,'')
        if l=~/:/
          if l =~ /1:/
            Thread.current["racers"][0] =  [1] * l.gsub(/1: /,'').to_i
          end
          if l =~ /2:/
            Thread.current["racers"][1] =  [2] * l.gsub(/2: /,'').to_i
          end
          if l =~ /3:/
            Thread.current["racers"][2] =  [3] * l.gsub(/3: /,'').to_i
          end
          if l =~ /4:/
            Thread.current["racers"][3] =  [4] * l.gsub(/4: /,'').to_i
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
