require 'thread'
require 'serialport.so'
class SprintSensor
  def initialize
    @blue = Queue.new
    @red = Queue.new
 
    @producer = Thread.new do
      sp = SerialPort.new('/dev/ttyUSB0', 115200, 8, 1, SerialPort::NONE)
      t_start = Time.now.to_f
      old_cts,old_dsr=sp.signals.values_at('cts','dsr')
     
      while true do
        cts,dsr = sp.signals.values_at('cts','dsr')
        t_now = Time.now.to_f
      #  cts is rider one aka red
      #  dsr is rider two aka blue
        if (cts==1) && (old_cts == 0)
          @red << t_now-t_start
        end
        if (dsr==1) && (old_dsr == 0)
          @blue << t_now-t_start
        end
        old_cts,old_dsr=cts,dsr
      end
    end
  end
 
  def read_red
    log = []
    @red.length.times do
      log << @red.pop
    end
    log
  end
  def read_blue
    log = []
    @blue.length.times do
      log << @blue.pop
    end
    log
  end
end
