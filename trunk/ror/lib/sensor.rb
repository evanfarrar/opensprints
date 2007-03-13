require 'serialport.so'
File.open("tmp/pids/sensor.#{Process.pid}","w+"){|f|}

sp = SerialPort.new('/dev/ttyUSB0', 115200, 8, 1, SerialPort::NONE)
t_start = Time.now.to_f
t_then = t_start
t_now = t_start

while true do
  sigs = sp.signals
  t_now = Time.now.to_f
#  cts is rider one aka red
#  dsr is rider two aka blue
  if sigs['cts']=1 && (t_now-t_then)>0.04
    File.open("log/sensor.log","a"){ |io| 
      io.puts "rider-one-tick: #{t_now-t_start}"
    }
  end
  if sigs['dsr']=1 && (t_now-t_then)>0.04
    File.open("log/sensor.log","a"){ |io| 
      io.puts "rider-two-tick: #{t_now-t_start}"
    }
  end
  t_then = t_now
end
File.delete("tmp/pids/sensor.#{Process.pid}","w+")
