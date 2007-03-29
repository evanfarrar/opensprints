require 'serialport.so'
File.open("log/sensor_pid.#{Process.pid}","w+"){|f|}

sp = SerialPort.new('/dev/ttyUSB0', 115200, 8, 1, SerialPort::NONE)
t_start = Time.now.to_f
old_cts,old_dsr=sp.signals.values_at('cts','dsr')
#t_then_one = t_then_two = t_start

while true do
  cts,dsr = sp.signals.values_at('cts','dsr')
  t_now = Time.now.to_f
#  cts is rider one aka red
#  dsr is rider two aka blue
  if (cts==1) && (old_cts == 0)
    puts "rider-one-tick: #{t_now-t_start}"
  end
  if (dsr==1) && (old_dsr == 0)
    puts "rider-two-tick: #{t_now-t_start}"
  end
  old_cts,old_dsr=cts,dsr
end
File.delete("log/sensor_pid.#{Process.pid}","w+")
