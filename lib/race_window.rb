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
    @race.racers.size.times do |i|
      @race.racers[i].ticks = @sensor.racers[i].size
    end

    @update_area.clear do
      @shoes_instance.app do
        stroke gray 0.5
        strokewidth 4

        line 2,0,2,100
        line 684,0,684,100
      end

      @race.racers.size.times do |i|
        @shoes_instance.stroke @bikes[i]
        @shoes_instance.fill @bikes[i]
        @shoes_instance.rect 6, 20+i*40, @bar_size*percent_complete(@race.racers[i]), 20
      end

      #FIXME this is hard to genericize...even by the power of splat
      @shoes_instance.subtitle(
        (@shoes_instance.span(@race.racers[0].name+' ',{:stroke => @bikes[0]}) if @race.racers[0]), 
        (@shoes_instance.span(@race.racers[1].name+' ',{:stroke => @bikes[1]}) if @race.racers[1]), 
        (@shoes_instance.span(@race.racers[2].name+' ',{:stroke => @bikes[2]}) if @race.racers[2]), 
        (@shoes_instance.span(@race.racers[3].name,{:stroke => @bikes[3]}) if @race.racers[3]), 
        {:top => 300, :align => 'center'})
      
      @race.racers.length.times do |i|
        @race.racers[i].finish_time = @sensor.racers[i][ticks_in_race]
      end

      if @race.complete?
        @sensor.stop
        results = []
        @race.racers.length.times do |i|
          results << "#{@race.racers[i].name}: #{@race.racers[i].finish_time/1000.0}s"
        end
        @shoes_instance.alert results.join(', ')
        @continue = false
        if @shoes_instance.owner.respond_to?(:tournament_record)
          @shoes_instance.owner.tournament_record(@race)
        end
      end
    end
  end

  def percent_complete(racer)
    [1.0, ((racer.ticks * racer.roller_circumference) || 0)/@race_distance.to_f].min
  end
  
  def ticks_in_race
    (@race_distance/@race.racers[1].roller_circumference)
  end

end

module RaceWindow
  def race_window(match, tournament=nil)
    window :title => TITLE, :width => 800, :height => 600 do
      race_distance, sensor, title = RACE_DISTANCE, SENSOR, TITLE
      background black
      bikes = BIKES.map{|b| eval b}

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
          if owner.respond_to?(:tournament_record)
            owner.tournament_record(match)
          end
        end

        if tournament && tournament.matches.length > 1
          subtitle("On deck: ",tournament.next_after(match).racers.join(', '),:stroke => white,
                   :top => 520)
          button("Next Race",{:top => 570, :left => 305}) do
            close
            owner.race_window(tournament.next_after(match),tournament)
          end
        end
      end
    end
  end
end
