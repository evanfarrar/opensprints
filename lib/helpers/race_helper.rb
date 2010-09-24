module RaceHelper
  def count_text(text)
    banner text, :font => "140px", :align => 'center'
  end

  def left_names(race)
    @left.clear { 
      stack do # start progress_bars
        race.race_participations.each_with_index do |racer,i|
          stack(:width => 1.0, :height => 81) {
            background(eval(racer.color), :width => 1.0, :height => 70)
            tagline(racer.racer.name, :margin => [10,10,0,0]).displace(0,0)
          }
        end
      end.displace(0,162) # end progress_bars
    }
  end

  def right_bars(race)
    @right.clear { 
      stack do # start progress_bars
        race.race_participations.each_with_index do |racer,i|
          fill right_bar_color||gradient(rgb(230,230,230),rgb(167,167,167), :angle => -90)
          stroke(black(0.0))
          rect(4,81*i+162,@right.width,69)
        end
      end.displace(0,162) # end progress_bars
    }
  end

  def race_track(race, race_started=false)
    self.send(RACE_TRACK, race, race_started)
  end

  def clock(race, race_started)
    @center.remove
    @left.style :width => WIDTH
    @left.clear do
      @clock = stack do
        fill gray(0.2)
        stroke black
        strokewidth 3

        center_x = @center.width/2
        center_y = @center.height/2
        oval :left => center_x, :top => center_y, :width => center_y * 2, :center => true

        fill white
        oval :left => center_x, :top => center_y, :width => center_y * 1.75, :center => true
        oval :left => center_x, :top => center_y, :width => center_y * 1.65, :center => true
        logo = image("media/logo-westcoast.png", :attach => Window, :top => center_y, :left => center_x - 220)

        # hashmarks
        8.times do |i|
          move_to(center_x,center_y)
          nofill
          stroke black
          big_hashes = ((2*Shoes::PI) * i/8)
          small_hashes = ((2*Shoes::PI) * i/8) + (Shoes::PI * 1/8)

          shape do
            strokewidth 40
            arc center_x,center_y,(center_y*1.65),(center_y*1.65),big_hashes + -0.01,big_hashes + 0.01
          end
          shape do
            strokewidth 12
            arc center_x,center_y,(center_y*1.70),(center_y*1.70),small_hashes + -0.005,small_hashes + 0.005
          end 
        end

        # clock-arms
        race.race_participations.each do |racer|
          strokewidth 5
          stroke eval(racer.color)
          progress_angle = ((racer.percent_complete * 2 * Shoes::PI) - 0.5 * Shoes::PI)
          opposite = progress_angle + Shoes::PI
          shape do
            move_to(center_x,center_y)
            arc_to(center_x,center_y,(center_y*2 - 20),(center_y*2 - 20),progress_angle,progress_angle)
            arc_to(center_x,center_y,(center_y - 40),(center_y - 40),opposite,opposite)
          end
        end

        fill black
        stroke black
        oval :left => center_x, :top => center_y, :width => 20, :center => true

        unless race_started && next_race = race.next_race
          @on_deck = stack(:attach => Window, :top => (window_height - 60), :left => 10, :width => (window_width/2), :height => 200) do
            if next_race = race.next_race
              tagline("up next: ", next_race.racers.join(", "), :stroke => white)
            end
          end
        end
      end

      # racer info
      @racers = stack do
        race.race_participations.each_with_index do |bike,index|
          stack(:attach => Window, :width => (WIDTH * 0.3).to_i, :left => (WIDTH * 0.7).to_i, :top => 100 + 160*index, :margin => [4,4,4,4]) do
            background eval(bike.color)
            stack do
              background gray(1.0,0.3)
              name = if bike.racer.name.length > 10 then bike.racer.name[0..10].concat('..') else bike.racer.name end
              title(name, :margin => [4,2,2,0], :stroke => white)
            end
            stack(:margin => [4,0,0,0]) do
              if bike.finished?
                subtitle("Finished: #{sprintf("%.2f", bike.finish_time)}", :margin => [0]*4, :stroke => white)
              else
                bike_speed = if race_started then bike.speed(bike.finish_time||SENSOR.time||0) else 0 end
                subtitle("#{sprintf('%.3d', bike_speed.to_i).rjust(5)} mph", :margin => [0]*4, :stroke => white)
                subtitle("#{sprintf('%.3d', [bike.distance.to_i, $RACE_DISTANCE].min).rjust(5)} m", :margin => [0]*4, :stroke => white)
              end
            end
          end
        end
      end
    end #left
  end

  def progress_bars(race,speed=false)
    left_names(race)
    right_bars(race)
    stack do # start progress_bars
      flow do
        race.race_participations.each_with_index do |racer,i|
          if speed
            flow(:width => 0.5){
              flow(:width => 0.5){
                title(racer.speed(racer.finish_time||SENSOR.time), :align => 'right',:margin => [0]*4,
                  :stroke => eval(racer.color))
              }
              flow(:width => 0.5){
                title("mph", :margin => [0]*4, :stroke => eval(racer.color))
              }
            }
          else
            flow(:width => 0.5){
              title(" ", :margin => [20]*4)
            }
          end
        end
      end
      race.race_participations.each_with_index do |racer,i|
        fill gradient(rgb(230,230,230),rgb(167,167,167), :angle => -90)
        stroke(black(0.0))
        rect(-1,81*i+162,@center.width+1,69)
        fill eval(racer.color)
        rect(-1,81*i+162,@center.width*racer.percent_complete+1,69)
        #oval(:radius => 34, :left => @center.width*racer.percent_complete+10, :top => 81*i+162)
      end
      
    end.displace(0,0) # end progress_bars
  end

  def stop_save_and_show_winner(race, id)
    @race_animation.stop
    SENSOR.stop
    race.raced = true
    race.save
    race.race_participations.map(&:save)
    visit "/races/#{id}/winner"
  end

  def swap_button(race,rerender_url)
    button($i18n.swap) {
      racers = race.racers.reverse
      race.race_participations.each{|rp|rp.destroy}
      racers.map {|r|
        RaceParticipation.create(:racer => r, :race => race)
      }
      visit rerender_url
    } 
  end

  def render_racer_name_and_color(race_participation,id)
    flow(:height => 0.3) {
      background(eval(race_participation.color), :width=> 0.9)
    }
    flow(:height => 0.3) {
      caption race_participation.racer.name
      delete_button {
        race_participation.destroy
        visit "/races/#{id}/edit"
      }
    }
    flow(:height => 0.3) {
      background(eval(race_participation.color), :width=> 0.9)
    }
  end
end
