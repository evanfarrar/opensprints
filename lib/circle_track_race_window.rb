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
    @race.racers.size.times do |i|
      @race.racers[i].ticks = @sensor.racers[i].size
    end

    @progress.clear do
      fill red
      stroke red
      strokewidth 200
      arc self.width/2, self.height/2, 
        450, 350, 
        0, Shoes::TWO_PI*(0.33)
      stroke white
      fill white
      arc self.width/2, self.height/2, 
        450, 350, 
        Shoes::TWO_PI*(0.33), 0
    end

    @progress_2.clear do
      fill blue
      stroke blue
      strokewidth 200
      arc self.width/2, self.height/2, 
        450, 350, 
        0, Shoes::PI
      stroke white
      fill white
      arc self.width/2, self.height/2, 
        450, 350, 
        Shoes::PI, 0
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
    window :title => TITLE, :width => 800, :height => 600 do
      race_distance, sensor, title = $RACE_DISTANCE, SENSOR, TITLE

      background lawngreen 

      stack do
        @progress_2 = stack
        mask do
          rect :top => height/2, :left => width/2, :center => true, :curve => 130,
            :width => 475, :height => 375, :strokewidth => 5
        end
        strokewidth 3
        rect :top => height/2, :left => width/2, :center => true, :curve => 130,
          :width => 475, :height => 375, :fill => rgb(0,0,0,0.0), :stroke => black
      end

      stack do
        @progress = stack
        mask do
          rect :top => height/2, :left => width/2, :center => true, :curve => 120,
            :width => 450, :height => 350, :strokewidth => 5
        end
        strokewidth 3
        rect :top => height/2, :left => width/2, :center => true, :curve => 120,
          :width => 450, :height => 350, :fill => rgb(0,0,0,0.0), :stroke => black
        rect :top => height/2, :left => width/2, :center => true, :curve => 110,
          :width => 420, :height => 320, :fill => lawngreen, :stroke => black

        title "OpenSprints", :top => height/2 - 40, :left => height/2 - 75
      end

      @progress.clear do
        fill red
        stroke red
        strokewidth 200
        arc self.width/2, self.height/2, 
          450, 350, 
          0, 0
        stroke white
        fill white
        arc self.width/2, self.height/2, 
          450, 350, 
          Shoes::TWO_PI*(0.001), 0
      end

      @progress_2.clear do
        fill blue
        stroke blue
        strokewidth 200
        arc self.width/2, self.height/2, 
          450, 350, 
          0, 0
        stroke white
        fill white
        arc self.width/2, self.height/2, 
          450, 350, 
          Shoes::TWO_PI*(0.001), 0
      end

      para("#### Finish", :top => height/2 - 10, :left => (width/2 + 205),
        :attach => Window, :weight => 'bold')

      stack do
        style :attach => Window, :top => 40, :curve => 40
        style :margin => [40, 0, 40, 0]
        border white, :curve => 40
        background gray(0.75, 0.8)
        title "Race Starting..."
        @counter = title "5.. "
        hide
      end

    end
  end
end
