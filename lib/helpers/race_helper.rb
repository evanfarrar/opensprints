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

  def race_track(race, speed=false)
    self.send(RACE_TRACK, race, speed)
  end

  def clock(race, speed)
    @center.remove
    @left.style :width => WIDTH
    @left.clear do
      @clock = stack do
        fill gray(0.2)
        stroke black
        strokewidth 3

        left = @center.width/2
        top = @center.height/2
        oval :left => left, :top => top, :width => top * 2, :center => true

        fill white
        oval :left => left, :top => top, :width => top * 1.75, :center => true
        oval :left => left, :top => top, :width => top * 1.65, :center => true
        image("media/big-logo.png", :attach => Window, :top => top - 15, :left => left - 110)

        8.times do |i|
          move_to(left, top)
          nofill
          stroke black
          big_hashes = ((2*Shoes::PI) * i/8)
          small_hashes = ((2*Shoes::PI) * i/8) + (Shoes::PI * 1/8)

          shape do
            strokewidth 40
            arc left, top, (top*1.65) , (top*1.65), big_hashes + -0.01, big_hashes + 0.01
          end
          shape do
            strokewidth 12
            arc left, top, (top*1.70) , (top*1.70), small_hashes + -0.005, small_hashes + 0.005
          end 
        end

        race.race_participations.each do |racer|
          strokewidth 5
          stroke eval(racer.color)
          progress_angle = ((racer.percent_complete * 2 * Shoes::PI) - 0.5 * Shoes::PI)
          opposite = progress_angle + Shoes::PI
          shape do
            move_to(left, top)
            arc_to(left,top,(top*2 - 20),(top*2 - 20),progress_angle,progress_angle)
            arc_to(left,top,top,top,opposite,opposite)
          end
        end

        fill black
        stroke black
        oval :left => left, :top => top, :width => 20, :center => true
      end
      @racers = stack do
        race.race_participations.each_with_index do |bike,index|
          stack(:attach => Window, :width => (WIDTH * 0.2).to_i, :left => (WIDTH * 0.8).to_i, :top => 100 + 100*index) do
            background eval(bike.color)
            stack do
              background gray(1.0, 0.2)
              caption(bike.racer.name[0..14])
            end
            caption(if speed then bike.speed(bike.finish_time||SENSOR.time||0) else 0 end, :margin => [0]*4)
            caption(bike.distance, :margin => [0]*4)
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
