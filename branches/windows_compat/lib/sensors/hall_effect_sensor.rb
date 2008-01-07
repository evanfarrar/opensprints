#hall_effect_sensor: a sensor written by luke orland using the UBW board
class Sensor
  def initialize(queue, filename=nil)
    @queue = queue
    @filename = filename
  end

  def start
    @t.kill if @t
    raise 'File Not Writable!' unless File.writable?(@filename)
    @t = Thread.new do
      if @filename =~ /^COM/
        @f = SerialPort.new(@filename, 115200, 8, 1, SerialPort::NONE)
      else
        @f = File.open(@filename, 'w+')
      end
      @f.putc 'g'
      @f.putc 'o'
      @f.putc "\n"
      while true do
        l = @f.readline
        if l=~/;/
          @queue << l
        end
        puts l
      end
    end
  end

  def stop
    @t.kill
    @f = File.open(@filename, 'w')
    @f.puts 'st'
    @f.close
  end
end
