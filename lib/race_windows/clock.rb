require 'lib/setup.rb'

module RaceWindow
  def race_window(match, tournament=nil)
    window :title => TITLE, :width => 800, :height => 600 do
      race_distance, sensor, window_title = $RACE_DISTANCE, SENSOR, TITLE
      if File.readable?('background.jpg')
        background 'background.jpg'
      else
        background black
      end

      puts BIKES
      bikes = BIKES.map{|b| eval b.downcase }

      stack do
        subtitle window_title, :top => 5, :stroke => white

        @count_box = stack(:top => 200)
        nofill
        line_width = 10.0
        strokewidth line_width
        stroke white
        outer_margin = 50
        max_diameter = [height, width].min
        left_edge,right_edge = outer_margin, max_diameter-outer_margin
        top_edge, bottom_edge = outer_margin, max_diameter-outer_margin
        clock_height = bottom_edge - top_edge
        @clock_center = clock_height / 2 + outer_margin
        @radius = clock_height / 2 - 10

        def clock_hand(color, percent_complete)
          _x = @radius * Math.sin( percent_complete * Math::PI / (50) )
          _y = @radius * Math.cos( percent_complete * Math::PI / (50) )
          stroke color
          strokewidth 4
          line(@clock_center, @clock_center, @clock_center + _x, @clock_center - _y)
        end

        oval left_edge, top_edge, clock_height
        cap :curve
        line left_edge, @clock_center, left_edge+30, @clock_center
        line right_edge, @clock_center, right_edge-30, @clock_center
        line @clock_center, top_edge, @clock_center, top_edge+30
        line @clock_center, bottom_edge, @clock_center, bottom_edge-30
        cap :square


        @start = button("Start Race",{:top => 570, :left => 10}) do
          @start.hide
          match.racers.each{|racer| racer.ticks = 0
                                    racer.finish_time = nil }
          sensor.start
          @countdown = 4
          @start_time = Time.now+@countdown
          @update_area = stack(:top => 0, :left => 0)

          @race_animation = animate(14) do
            @now = Time.now
            if @now < @start_time
              @count_box.clear do
                banner "#{(@start_time-@now).round}...", :stroke => ivory,
                  :font => "Arial 200px", :align => 'center'
              end
            else
              @count_box.remove if @count_box
              @count_box = nil
              if match.complete?
                @start.show
                @race_animation.stop
                @sensor.stop
                if owner.respond_to?(:tournament_record)
                  owner.tournament_record(@race)
                end
              else
                @update_area.clear do
                  match.racers.each_with_index do |racer,i|
                    racer.ticks = sensor.racers[i].size
                    clock_hand(bikes[i], match.percent_complete(racer)*100)
                  end
                end
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
