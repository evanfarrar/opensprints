#Arduino: a sensor written for the arduino open source hardware.
class Sensor
  #attr_accessor :queue
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
      racer_1 = 0
      racer_2 = 0

      until racer_1 >= 2000 && racer_2 >= 2000
        if (rand(2) == 1 && racer_1 < 2000)
          f << "1: #{racer_1 += rand(35)}"
        else
          f << "2: #{racer_2 += rand(35)}"
        end
      end
      wins = ["1f: #{racer_1}", "2f: #{racer_2}"]
      (racer_1 >= racer_2) ? f.concat(wins) : f.concat(wins.reverse)

      t_start = Time.now.to_f
      until !Thread.current["red_finish"].nil? && !Thread.current["blue_finish"].nil? do
        l = f.shift
        sleep (rand(50))/1000.0

        if l =~ /1:/
          Thread.current["red"] = l.gsub(/1: /,'').to_i
        end
        if l =~ /2:/
          Thread.current["blue"] = l.gsub(/2: /,'').to_i
        end
        if l =~ /1f:/
          Thread.current["red_finish"] = (Time.now.to_f - t_start).to_i
        end
        if l =~ /2f:/
          Thread.current["blue_finish"] = (Time.now.to_f - t_start).to_i
        end

        if l
          @queue << l
          puts l
        end
      end
    end
    self
  end

  def values
    @values ||= {:red => 1, :blue => 1,
     :red_finish => @t["red_finish"], :blue_finish => @t["blue_finish"]}
    if @t["red"] || @t["blue"] #something not nil?
      @values = {:red => @t["red"], :blue => @t["blue"],
       :red_finish => @t["red_finish"], :blue_finish => @t["blue_finish"]}
    end
    @values
  end

  def stop
    @t.kill
  end
end
