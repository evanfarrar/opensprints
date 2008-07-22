#Arduino: a sensor written for the arduino open source hardware.
class Sensor
  attr_accessor :queue
  def initialize(queue, filename=nil)
    @queue = queue
    raise 'File Not Writable!' unless File.writable?(filename)
    #HACK oogity boogity magic happens here:
    `stty -F #{filename} cs8 115200 ignbrk -brkint -icrnl -imaxbel -opost -onlcr -isig -icanon -iexten -echo -echoe -echok -echoctl -echoke -noflsh -ixon -crtscts`
    @f = File.open(filename, 'w+')
  end

  def start
    @t.kill if @t
    @t = Thread.new do
      @f.putc 'g'
      @f.flush
      while true do
        l = @f.readline
        if l=~/:/
          if l =~ /1:/
            Thread.current["red"] = l.gsub(/1: /,'').to_i
          end
          if l =~ /2:/
            Thread.current["blue"] = l.gsub(/2: /,'').to_i
          end
          if l =~ /1f:/
            Thread.current["red_finish"] = l.gsub(/1f: /,'').to_i
          end
          if l =~ /2f:/
            Thread.current["blue_finish"] = l.gsub(/2f: /,'').to_i
          end
        end
        puts l
      end
    end
    self
  end

  def values
    {:red => @t["red"], :blue => @t["blue"],
     :red_finish => @t["red_finish"], :blue_finish => @t["blue_finish"]}
  end

  def stop
    @f.puts 's'
    @f.flush
    @t.kill
  end
end
