#hall_effect_sensor: a sensor written by luke orland using the UBW board
class Sensor
  def initialize(queue, filename=nil)
    @queue = queue
    @filename = filename
  end

  def start
    @t.kill if @t
    @f = File.open(@filename, 'w+')
    @t = Thread.new do
      @f.puts 'go'
      while true do
        l = @f.readline
        if l=~/;/
          @queue << l
        end
        puts l
      end
    end
    # I forgot why start returns self.
    self
  end

  def stop
    @t.kill
    @f = File.open(@filename, 'w+')
    @f.puts 'st'
    @f.close
  end
end
