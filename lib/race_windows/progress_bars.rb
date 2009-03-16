require 'lib/setup.rb'

class RacePresenter
  def initialize(shoes_instance, distance, update_area, race, sensor, bikes, best_time)
    @shoes_instance = shoes_instance
    @bar_size = 800-2*60-6
    @race_distance = distance
    @race = race
    @update_area = update_area
    @sensor = sensor
    @continue = true
    @bikes = bikes
    @best_time = best_time
  end

  def continue?; @continue end

  def refresh
    current_time = @sensor.time
    @race.racers.each_with_index do |racer, i|
      racer.ticks = @sensor.racers[i].size unless racer.finish_time
      racer.text.replace(racer.name, ': ', racer.speed(current_time), "mph")
    end

    @update_area.clear do
      fudge_right = (@shoes_instance.width-@bar_size)/2

      #ghost lap
      if @best_time
        @shoes_instance.stroke gray 0.3
        @shoes_instance.fill gray 0.3

        @shoes_instance.rect fudge_right+6, 5, @bar_size*([1.0,(@sensor.time / 1000.0) / @best_time].min), 5+@race.racers.length*40
      end


      @shoes_instance.stroke gray 0.5
      @shoes_instance.strokewidth 4

      @shoes_instance.line fudge_right+2, 0,fudge_right+2,20+@race.racers.length*40
      @shoes_instance.line fudge_right+684, 0,fudge_right+684,20+@race.racers.length*40


      @race.racers.size.times do |i|
        @shoes_instance.stroke @bikes[i]
        @shoes_instance.fill @bikes[i]
        @shoes_instance.rect fudge_right+6, 20+i*40, @bar_size*percent_complete(@race.racers[i]), 20
      end

      @race.racers.each_with_index do |racer,i|
        racer.finish_time = @sensor.finish_times[i]
        racer.text.replace("#{racer.name}: #{racer.speed(racer.finish_time)}mph #{racer.finish_time/1000.0}s") if racer.finish_time
      end

      if @race.complete?
        @sensor.stop
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
    (@race_distance/@race.racers[0].roller_circumference)
  end

end

include Sorty
module RaceWindow
  def race_window(match, tournament=nil)
    window :title => TITLE, :width => 800, :height => 600 do
      def list_racers(match, bikes)
        flow(:attach => Window, :top => 40*match.racers.size+240, :margin => [80,0,0,0]) do
          match.racers.each_with_index do |racer, index|
            stack(:width => 300, :margin => [20, 10, 20, 0], :curve => 10) do
              background white, :curve => 12
              lighter = rgb(bikes[index].red,bikes[index].green,bikes[index].blue, 0.7)
              background lighter, :curve => 12
              border bikes[index], :curve => 8, :strokewidth => 4
              racer.text = caption(racer.name, ': ', racer.speed(0), "mph")
            end
          end
        end
      end
      race_distance, sensor, window_title = $RACE_DISTANCE, SENSOR, TITLE
      if File.readable?('background.jpg')
        background 'background.jpg'
      else
        background black
      end

      puts BIKES
      bikes = BIKES.map{|b| eval b.downcase }

      stack do
        subtitle window_title, :top => 60, :align => "center", :background => magenta,
          :stroke => white

        @update_area = stack(:top => 200, :attach => Window)

        list_racers(match, bikes)

        @start = button("Start Race",{:top => 570, :left => 10}) do
          @start.hide
          match.racers.each{|racer| racer.ticks = 0 }
          match.racers.each{|racer| racer.finish_time = nil }
          r = RacePresenter.new(self, race_distance, @update_area,
                       match, sensor, bikes, (tournament.best_time if tournament))

          sensor.start
          @countdown = 4
          @start_time = Time.now+@countdown
          @update_area.clear { @count_box = stack }

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
                flow(:align => 'center', :top => 100, :attach => Window) do
                  background rgb(255,255,255,0.60)
                  banner "#{match.winner} wins!", :stroke => black,
                    :font => "Arial 200px", :align => 'center'
                end
                @race_animation.stop
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
          flow(:align => 'center', :top => 100, :attach => Window) do
            background rgb(255,255,255,0.60)
            banner "#{match.winner} wins!", :stroke => black,
              :font => "Arial 200px", :align => 'center'
          end
          @race_animation.stop
          @continue = false
          if owner.respond_to?(:tournament_record)
            owner.tournament_record(match)
          end
        end
        button("change bikes", {:top => 570, :left => 300}) do
          sort_names(match, bikes) { list_racers(match, bikes); owner.relist_tournament }
        end
        
        if tournament && tournament.matches.length > 1
          subtitle("On deck: ",tournament.next_after(match).racers.join(', '),:stroke => white,
                   :top => 520)
          button("Next Race",{:top => 570, :left => 430}) do
            close
            owner.race_window(tournament.next_after(match),tournament)
          end
        end
      end
    end
  end
end
