#Arduino: a sensor written for the arduino open source hardware.
class Sensor
  attr_accessor :queue
  def initialize(queue, filename=nil)
    @queue = queue
  end

  def start
    @queue.clear
    @t.kill if @t
    @t = Thread.new do
      t = 0
      f = []
      sleep 5
      2000.times {|i| f << "#{rand(2)+1}: #{i}"}
      [1,2].sort_by{rand}.each {|i| f << "#{i}f: #{1+rand(1000)}"}
      t_start = Time.now.to_f
      while true do
        l = f.shift
        sleeptime = l.split[1].to_f/1000.0 - (Time.now.to_f - t_start)
        sleep sleeptime if sleeptime > 0

        if l =~ /1:/
          Thread.current["red"] = l.gsub(/1: /,'').to_i
        end
        if l =~ /2:/
          Thread.current["blue"] = l.gsub(/2: /,'').to_i
        end
        if l =~ /1f:/
          Thread.current["red_finish"] = l.gsub(/1f: /,'').to_i
        end
        if l =~ /2f:/
          Thread.current["blue_finish"] = l.gsub(/2f: /,'').to_i
        end

        @queue << l
        puts l
      end
    end
    self
  end

  def values
    {:red => @t["red"], :blue => @t["blue"],
     :red_finish => @t["red_finish"], :blue_finish => @t["blue_finish"]}
  end

  def stop
    @t.kill
  end
end
