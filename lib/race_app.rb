require 'lib/setup.rb'

class RacePresenter
  def initialize(shoes_instance, distance, update_area, race, sensor, bikes)
    @shoes_instance = shoes_instance
    @bar_size = 800-2*60-6
    @race_distance = distance
    @race = race
    @update_area = update_area
    @sensor = sensor
    @continue = true
    @bikes = bikes
  end

  def continue?; @continue end

  def refresh
    @bikes.size.times do |i|
      @race.racers[i].ticks = @sensor.racers[i].size
    end

    @update_area.clear do
      fudge_right = (@shoes_instance.width-@bar_size)/2
      fudge_down = 220

      @shoes_instance.stroke gray 0.5
      @shoes_instance.strokewidth 4

      @shoes_instance.line fudge_right+2,fudge_down,fudge_right+2,fudge_down+20+@race.racers.length*40
      @shoes_instance.line fudge_right+684,fudge_down,fudge_right+684,fudge_down+20+@race.racers.length*40


      @race.racers.size.times do |i|
        @shoes_instance.stroke @bikes[i]
        @shoes_instance.fill @bikes[i]
        @shoes_instance.rect fudge_right+6, fudge_down+20+i*40, @bar_size*percent_complete(@race.racers[i]), 20
      end

      @race.racers.each_with_index do |e,i|
        e.finish_time = @sensor.finish_times[i]
      end


      if @race.complete?
        @sensor.stop
        results = []
        @race.racers.length.times do |i|
          results << "#{@race.racers[i].name}: #{@race.racers[i].finish_time/1000.0}s"
        end
        @shoes_instance.alert results.join(', ')
        @continue = false

        @shoes_instance.close
      end
    end
  end

  def percent_complete(racer)
    [1.0, ((racer.ticks * racer.roller_circumference) || 0)/@race_distance.to_f].min
  end
  
  def ticks_in_race
    (@race_distance/$ROLLER_CIRCUMFERENCE)
  end

end
Shoes.app :title => TITLE, :width => 800, :height => 600 do
  racers = BIKES.map{|b| Racer.new(:name => b, :units => UNIT_SYSTEM)}
  match = Race.new(racers, $RACE_DISTANCE)
  bikes = BIKES.map{|b| eval b.downcase }
  race_distance, sensor, title = $RACE_DISTANCE, SENSOR, TITLE
  if File.readable?('background.jpg')
    background 'background.jpg'
  else
    background black
  end

  stack do
    subtitle title, :top => 150, :align => "center", :background => magenta,
      :stroke => white
    @update_area = stack {}

    def hide_start
      @start.hide
    end

    @start = button("Start Race",{:top => 570, :left => 10}) do
      hide_start
      r = RacePresenter.new(self, race_distance, @update_area,
                   match, sensor, bikes)
      
      sensor.start
      @countdown = 4
      @start_time = Time.now+@countdown
      @update_area.clear {
        @count_box = stack(:top => 200){   }
      }

      @race_animation = animate(14) do
        @now = Time.now
        if @now < @start_time
          @count_box.clear do
            banner "#{(@start_time-@now).round}...", :stroke => ivory,
              :font => "Arial 200px", :align => 'center'
          end
        else
          @count_box.remove
          if r.continue?
            r.refresh
          else
            @start.show
          end
        end
      end
    end

    button("Quit", {:top => 570, :left => 135}) do
      @race_animation.stop if @race_animation
      close
    end

    button("Call it", {:top => 570, :left => 205}) do
      sensor.stop
      results = []
      bikes.length.times do |i|
        results << "#{match.racers[i].name}: #{match.racers[i].finish_time/1000.0}s" if match.racers[i].finish_time
      end
      alert results.join(', ')
      @continue = false
    end


  end
end
