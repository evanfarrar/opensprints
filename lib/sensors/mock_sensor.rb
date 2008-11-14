#Arduino: a sensor written for the arduino open source hardware.
class Sensor
  attr_accessor :queue, :r
  def initialize(queue, filename=nil)
  end

  def start
    @start = Time.now
    @t = Thread.new do
      loop do
        fake = sixty_times_a_sec
        Thread.current["vals"] = {
                                   :red => fake, 
                                   :blue => fake,
                                   :green => fake,
                                   :yellow => fake
                                 }
      end
    end
  end

  def values
    @t["vals"]
  end

  def sixty_times_a_sec
    [(Time.now - @start)*1000] * (Time.now - @start)*60
  end

  def stop
    @t.kill
  end
end
