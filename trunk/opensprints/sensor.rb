require 'serialport.so'
File.open("log/sensor_pid.#{Process.pid}","w+"){|f|}
#IO.open($stdout,"w+"){|f|}

sp = SerialPort.new('/dev/ttyUSB0', 9600, 8, 1, SerialPort::NONE)
t_start = Time.now.to_f
t_then_one = t_then_two = t_start

while true do
  sigs = sp.signals
  t_now = Time.now.to_f
#  cts is rider one aka red
#  dsr is rider two aka blue
  if sigs['cts']==1 && (t_now-t_then_one)>0.005
    puts "rider-one-tick: #{t_now-t_start}"
    t_then_one=t_now
  end
  if sigs['dsr']==1 && (t_now-t_then_two)>0.005
    puts "rider-two-tick: #{t_now-t_start}"
    t_then_two=t_now
  end
end
#File.delete("tmp/pids/sensor.#{Process.pid}","w+")
