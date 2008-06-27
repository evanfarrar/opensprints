#hall_effect_sensor: a sensor written by luke orland using the UBW board
#Uses the serialtun by Brandon Creighton for reading off of the UBW.
require 'socket'
class Sensor
  def initialize(queue, filename=nil)
    @queue = queue
    @filename = filename
  end

  def start
    Thread.abort_on_exception = true 
    @t.kill if @t
    @t = Thread.new do
      @f = File.new(@filename, 'w+')
      @f.putc 'h'
      @f.putc 'w'
      @f.putc "\n"
      while true do
        l = @f.readline
        if l=~/^[12];/
          @queue << l
        end
        puts l
      end
    end
  end
  def stop
    @t.kill
    @s.close
  end
end

