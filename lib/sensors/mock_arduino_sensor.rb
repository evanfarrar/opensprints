#Arduino: a sensor written for the arduino open source hardware.
class Sensor
  attr_accessor :queue
  def initialize(queue, filename=nil)
    @queue = queue
    raise 'File Not Writable!' unless File.writable?(filename)
    @f = File.open(filename, 'w+')
  end

  def start
    @t.kill if @t
    @t = Thread.new do
      @f.puts 'm'
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
    @t.kill
  end
end
