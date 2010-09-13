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

  def race_track(race,speed=false)
    progress_bars(race, speed)
  end

  def progress_bars(race,speed=false)
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
