require 'serialport.so'

sp = SerialPort.new('/dev/ttyUSB0', 9600, 8, 1, SerialPort::NONE)

open("/dev/tty", "r+") { |tty|
  tty.sync = true
  Thread.new {
    while true do
      tty.printf("%c", sp.getc)
    end
  }
  while (l = tty.gets) do
    sp.write(l.sub("\n", "\r"))
  end

}

sp.close
