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
          @queue << l
        end
        puts l
      end
    end
    self
  end

  def stop
    @f.puts 's'
    @f.flush
    @t.kill
  end
end
