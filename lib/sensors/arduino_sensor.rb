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
      @f = File.open(@filename, 'w+')
      @f.putc 'g'
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
    @f.putc 's'
    @f.close
    @t.kill
  end
end
