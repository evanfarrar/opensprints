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
      sp = SerialPort.new(@filename, 115200)
      sp.putc 'g'
      sp.putc 'o'
      sp.putc "\n"
      sp.close

      @s = TCPSocket.new('127.0.0.1',5000)
      loop do
        @queue << @s.readline.strip
      end
    end
  end
  def stop; end
end
