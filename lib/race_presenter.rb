module RacePresenterMod
  def race_window(match, race_distance, sensor_location, title)
    window :title => title, :width => 800, :height => 600 do
      background "media/trappedsprints-800.jpg"

      stack do
        banner title, :top => 150, :align => "center", :background => magenta,
          :stroke => white
        @update_area = stack {}
        race = lambda do
          @start.hide
          r = RacePresenter.new(self, race_distance, @update_area,
                       match, sensor_location)
          
          @countdown = 5
          @start_time = Time.now+5
          count_box = stack{ @label = banner "#{@countdown}..." }
          @race_animation = animate(14) do
            @now = Time.now
            if @now < @start_time
              count_box.clear do
                banner "#{(@start_time-@now).round}...", :stroke => white
              end
            else
              count_box.remove
              r.refresh
              @start.show unless r.continue?
            end
          end
        end
        @start = button("Start Race") do
          race.call
        end

        button("Quit") do
          @race_animation.stop if @race_animation
          close
        end
      end
    end
  end

end
class RacePresenter
  attr_accessor :winner
  def initialize(shoes_instance, distance, update_area, race, sensor_location)
    @shoes_instance = shoes_instance
    @bar_size = 800-2*60
    @race_distance = distance
    @race = race
    @red = @race.red_racer
    @blue = @race.blue_racer
    @update_area = update_area
    @sensor_location = sensor_location
  end

  def continue?; @continue end

  def refresh
    unless @started
      @queue = Queue.new
      @sensor = Sensor.new(@queue, @sensor_location)
      @sensor.start
      @started=true
      @continue = true
    end
    partial_log = []
    @queue.length.times do
      q = @queue.pop
      if q =~ /;/
        partial_log << q
      end
    end
    if (partial_log=partial_log.grep(/^[12]/)).any?
      if (blue_log = partial_log.grep(/^2/))
        @blue.update(blue_log)
      end
      if (red_log = partial_log.grep(/^1/))
        @red.update(red_log)
      end
      @update_area.clear do
        @shoes_instance.stroke gray 0.5
        @shoes_instance.strokewidth 4
        @shoes_instance.line 60-4,280,60-4,380
        @shoes_instance.line 800-60+4,280,800-60+4,380
        blue_progress = @bar_size*percent_complete(@blue)
        @shoes_instance.stroke "#00F"
        @shoes_instance.fill "#FEE".."#32F", :angle => 90, :radius => 10
        @shoes_instance.rect 60, 300, blue_progress, 20 
        
        red_progress = @bar_size*percent_complete(@red)
        @shoes_instance.stroke "#F00"
        @shoes_instance.fill "#FEE".."#F23", :angle => 90, :radius => 10
        @shoes_instance.rect 60, 340, red_progress, 20 
        if @blue.distance>@race_distance and @red.distance>@race_distance
          if (@red.tick_at(@race_distance)<@blue.tick_at(@race_distance)) 
            self.winner = @red
            @red.wins += 1
            @blue.losses += 1
          else
            self.winner = @blue
            @red.losses += 1
            @blue.wins += 1
          end
          @red.record_time(@red.tick_at(@race_distance))
          @blue.record_time(@blue.tick_at(@race_distance))
          @shoes_instance.title "#{self.winner.name.upcase} WINS!!!\n", :align => "center",
            :top => 380, :width => 800, :stroke => @shoes_instance.white
          @shoes_instance.title "#{@red.name}: #{@red.tick_at(@race_distance)}s, #{@blue.name}: #{@blue.tick_at(@race_distance)}s", :stroke => @shoes_instance.white,
            :align => 'center', :top => 450, :width => 800
          @sensor.stop
          @continue = false
          @race.red_racer = @red
          @race.blue_racer = @blue
          @shoes_instance.owner.tournament_record(@race)
          @shoes_instance.owner.post_race
        end
      end    
    end
  end

  def stop
    @sensor.stop
  end

  def percent_complete(racer)
    [1.0, racer.distance/@race_distance.to_f].min
  end
end
