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
    @bikes = bikes[0..1]
    @best_time = best_time
  end

  def continue?; @continue end

  def refresh
    @race.racers.each_with_index do |racer, i|
      racer.ticks = @sensor.racers[i].size
      racer.text.replace(strong(racer.speed(@sensor.time)))
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
        racer.text.replace(strong("%.2fs" % (racer.finish_time/1000.0)))
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

module RaceWindow
  def race_window(match, tournament=nil)
    font("lib/DINMittelschriftStd.otf")
    window :title => TITLE, :width => 800, :height => 600 do
      style(Shoes::Title, :family => 'DIN 1451 Std')
      style(Shoes::Caption, :family => 'DIN 1451 Std')
      style(Shoes::Para, :family => 'DIN 1451 Std')

      race_distance, sensor, window_title = $RACE_DISTANCE, SENSOR, TITLE
      background gradient("#3c3334","#8c7877")

      bikes = BIKES.map{|b| eval b.downcase }

      stack :margin_left => 20 do
        title window_title, :family => 'DIN 1451 Std', :top => 40, :stroke => yellow
        stroke "#cbc3c0"
        line 0,90,760,90

        flow(:width => 20,
                          :height => 200,
                          :top => 100,
                          :left => 10 ) do
          background "#cbc3c0"
          transform(:center)
          rotate 90
          para "START", :top => 170, :left => 0

        end
        flow(:width => 20,
                          :height => 200,
                          :top => 100,
                          :left => 730 ) do
          background "#cbc3c0"
          transform(:center)
          rotate 90
          para "FINISH", :top => 170, :left => 0

        end
        line 10,100,740,100
        line 10,115,740,115
        line 10,130,740,130
        line 10,145,740,145
        line 10,299,740,299

        @update_area = stack(:top => 200, :attach => Window)

        flow(:attach => Window, :top => 40*match.racers.size+240, :margin => [0,0,0,0]) do
          match.racers.each_with_index do |racer, index|
            stack(:width => 250, :margin => [20, 10, 20, 0]) do
              lighter = rgb(bikes[index].red,bikes[index].green,bikes[index].blue, 0.7)
              background "#3c3334"
              background lighter
              flow do
                background bikes[index]
                fill("#3c3334")
                para racer.name
              end
              stroke bikes[index]
              fill bikes[index]
              racer.text = banner(strong(racer.speed(0)), :stroke => bikes[index])
            end
          end
        end

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
