#mock_sensor: a sensor that you can use without real sensors attached
class Sensor
  attr_accessor :queue
  def initialize(queue, filename=nil)
    @queue = queue
    @filename = nil
  end

  def start
    @queue.clear
    @t.kill if @t
    @t = Thread.new do
      t = 0
      f = []
      8000.times { f << "#{rand(2)+1}: #{t+=rand(100)}" }
      t_start = Time.now.to_f
      while true do
        l = f.shift
        sleeptime = l.split[1].to_f/1000.0 - (Time.now.to_f-t_start)
        sleep sleeptime if sleeptime > 0
        @queue << l 
        puts l
      end
    end
 
    self
  end

  def stop
    @t.kill
  end

end

class Float
  def naturalize
    self > 0 ? self : 0
  end
end
