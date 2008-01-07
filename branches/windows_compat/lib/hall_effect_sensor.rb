Kernel::require Dir.pwd+'/serialport.so'
#hall_effect_sensor: a sensor written by luke orland using the UBW board

Shoes.app do
@f = SerialPort.new("COM6", 115200, 8, 1, SerialPort::NONE)
@f.putc 'g'
@f.putc 'o'
@f.putc "\n"
para "hey"
animate(1) do
  l = @f.readline
  para l
end
end