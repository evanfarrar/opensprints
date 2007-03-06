require 'serialport.so'

sp = SerialPort.new('/dev/ttyUSB0', 9600, 8, 1, SerialPort::NONE)

open("log/serial.log", "r+") { |log|
  while true do
    if 
    log.puts sp.getc
  end
}

sp.close
