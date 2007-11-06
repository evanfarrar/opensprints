require 'socket'
require 'serialport.so'
class Sensor
  def initialize(queue, filename=nil)
    @queue = queue
    @filename = filename
  end

  def start
    @t.kill if @t
    @t = Thread.new do
      sp = SerialPort.new('/dev/ttyUSB0', 115200, 8, 1, SerialPort::NONE)
      t_start = Time.now.to_f
      old_cts_time = t_start
      old_dsr_time = t_start
      old_cts,old_dsr=sp.signals.values_at('cts','dsr')
 
      while true do
        cts,dsr = sp.signals.values_at('cts','dsr')
        t_now = Time.now.to_f
      #  cts is rider one aka red
      #  dsr is rider two aka blue
        if (cts==1) && (old_cts == 0) && ((t_now - old_cts_time) > 0.05)
          old_cts_time = t_now
          @queue << "1: #{t_now-t_start}"
        end
        if (dsr==1) && (old_dsr == 0) && ((t_now - old_dsr_time) > 0.05)
          old_dsr_time = t_now
          @queue << "2: #{t_now-t_start}"
        end
        old_cts,old_dsr=cts,dsr
      end
    end
 
    self
  end

  def stop
    @t.kill
  end
end
