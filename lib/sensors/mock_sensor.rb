#mock_sensor: a sensor that you can use without real sensors attached
class Sensor
  def initialize(queue, filename=nil)
    @queue = queue
    @filename = nil
  end

  def start
    @t.kill if @t
    @t = Thread.new do
      if @filename
        f = File.readlines(@filename, 'w+')
      else
        t = 0
        f = []
        800.times { f << "#{rand(2)+1};0:#{t+=rand(10)}" }
      end
      t_start = Time.now.to_f
      while true do
        l = f.shift
          sleep (SecsyTime.parse(l.split(';')[1]).in_seconds - (Time.now.to_f-t_start)).naturalize
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
