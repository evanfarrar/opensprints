require 'socket'
s = TCPSocket.new( "localhost", 5000 )
f = File.open('/dev/ttyACM0')

while true do
  l = f.readline
  s.puts l
  puts l
end
