require 'lib/setup.rb'

class Shoes::ColoredProgressBar < Shoes::Widget
  def initialize(percent,top,color)
    stroke color
    fill color
    rect 6, top, percent, 20
  end
end

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
    @race.racers[0].ticks = @sensor.racers[0].size
    @race.racers[1].ticks = @sensor.racers[1].size

    @update_area.clear do
      @shoes_instance.stroke gray 0.5
      @shoes_instance.strokewidth 4

      @shoes_instance.line 2,0,2,100
      @shoes_instance.line 684,0,684,100

      @shoes_instance.colored_progress_bar(@bar_size*percent_complete(@race.racers[0]), 20, @bikes[0])
      
      @shoes_instance.colored_progress_bar(@bar_size*percent_complete(@race.racers[1]), 60, @bikes[1])

      @shoes_instance.subtitle(
        @shoes_instance.span(@race.racers[0].name,{:stroke => @bikes[0]}), 
        @shoes_instance.span(" vs ",{:stroke => @shoes_instance.ivory}),
        @shoes_instance.span(@race.racers[1].name,{:stroke => @bikes[1]}),
        {:top => 300, :align => 'center'})
      
      @race.racers[0].finish_time = @sensor.racers[0][ticks_in_race]
      @race.racers[1].finish_time = @sensor.racers[1][ticks_in_race]

      if @race.complete?
        @sensor.stop
        @shoes_instance.alert "#{@race.racers[1].name}: #{@race.racers[1].finish_time/1000.0}s, #{@race.racers[0].name}: #{@race.racers[0].finish_time/1000.0}s"
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
        
        if tournament.matches.length > 1
          subtitle "On deck: ",tournament.next_after(match).racers.join(', '),:stroke => white
          button("Next Race",{:top => 570, :left => 300}) do
            close
            owner.race_window(tournament.next_after(match),tournament)
          end
        end
      end
    end
  end
end
