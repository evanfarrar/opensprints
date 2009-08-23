module RaceHelper
  # Returns an array of the format:
  # [["joe", "red"], ["vs.", "white],["nick","blue"]]
  def names_to_colors(racers)
    racers.join(" vs. ").split(' ').zip($BIKES.join(" white ").split(' '))
  end

  def count_text(text)
    banner text, :font => "140px", :stroke => white, :align => 'center'
  end
end

class RaceController < Shoes::Main
  include RaceHelper
  url '/races/(\d+)/ready', :ready
  url '/races/(\d+)/countdown', :countdown
  url '/races/(\d+)', :show
  url '/races/(\d+)/winner', :winner
  url '/races/(\d+)/edit', :edit


  def ready(id)
    nav
    race = Race.get(id)

    stack {
      names_to_colors(race.racers).each {|word,color|
        subtitle(word.upcase,:font => "Helvetica Neue Bold ", :stroke => eval(color), :align => 'center',:margin => [0]*4)
      }
    }

    para(link "Start", :click => "/races/#{id}/countdown")
    para(link "Edit Race", :click => "/races/#{id}/edit")
  end

  def countdown(id)
    nav
    race = Race.get(id)
    clear do
      @counter = stack(:height => HEIGHT/3)
    end
    @timer = animate(1) { |count|
      case count
      when 4
        @counter.clear do
          background(rgb(200,0,0, 0.7))
          count_text("GO!!!")
        end
      when 1
        SENSOR.start
        @counter.clear do
          background(rgb(200,0,0, 0.7))
          count_text(4-count)
        end
      when 0..4
        @counter.clear do
          background(rgb(200,0,0, 0.7))
          count_text(4-count)
        end
      else
        @timer.stop
        visit "/races/#{id}"
      end
    }

  end

  def show(id)
    nav
    race = Race.get(id)
    para(link "Call It", :click => lambda{
      @race_animation.stop
      SENSOR.stop
      race.save
      visit "/races/#{id}/winner"
    })
    @center = flow(:width => 0.90) { }
    @race_animation = animate(14) do
      if race.finished?
        @race_animation.stop
        SENSOR.stop
        race.save
        visit "/races/#{id}/winner"
      else
        @center.clear do
          race.race_participations.each_with_index do |racer,i|
            racer.ticks = SENSOR.racers[i].size
            if SENSOR.finish_times[i]
              racer.finish_time = SENSOR.finish_times[i] / 1000.0
            end
          end
          stack do
            race.race_participations.each_with_index do |racer,i|
              flow {
                stack(:width => 0.92) {
                  background(eval(racer.color), :width => racer.percent_complete, :height => 80)
                  subtitle(racer.racer.name,":", :stroke => white, :font => "Helvetica Neue Bold", :margin => [0]*4).displace(0,-10)
                  subtitle(racer.speed(racer.finish_time||SENSOR.time),"mph", :stroke => white, :font => "Helvetica Neue Bold", :margin => [0]*4).displace(0,-28)
                }
              }
            end
          end
        end
      end
    end

  end

  def winner(id)
    race = Race.get(id)
    winner = race.winner
    background eval(winner.color+"(0.6)")
    nav
    para(link "tournament", :click => "/tournaments/#{race.tournament_id}")
    stack(:top => 40, :left => 0) do
      banner "WINNER IS "+winner.racer.name.upcase, :font => "Bold", :stroke => white, :align => "center"
      race.race_participations.each{|r|
        if r.finish_time
          subtitle("#{r.racer.name}: #{"%.2f" % r.finish_time} seconds", :stroke => white)
        else
          subtitle("#{r.racer.name}: DNF", :stroke => white)
        end
          
      }
    end
  end

  def edit_off(id)
    colors = $BIKES.map{|b|eval(b)}
    @next_color = colors.cycle
    @next_color.next
    race = Race.get(id)

    @previous_color = colors.cycle
    (colors.length - 1).times { @previous_color.next }

    names_n_colors(race.racers, colors, race)
  end

  def edit(id)
    race = Race.get(id)
    stack do
      race.race_participations.each do |race_participation|
        flow(:height => 70, :width => 400) do
          border eval(race_participation.color), :strokewidth => 4
          subtitle race_participation.racer.name
          
          para( "move to:")
          list_box(:items => $BIKES) do |list|
            new_color = list.text
            racer = race_participation.racer
            racers = race.racers
            old_index = racers.index(racer)
            new_index = $BIKES.index(new_color)
            racers[new_index],racers[old_index] = racer,racers[new_index] 
            race.race_participations.destroy!
            racers.map {|r|
              race.race_participations.create(:racer => r)
            }
            visit "/races/#{id}/edit"
          end
          para(link "delete", :click => lambda {
            race_participation.destroy
            visit "/races/#{id}/edit"
          })
        end
      end
    end
    if($BIKES.length > race.race_participations.count)
      list_box(:items => race.tournament.unmatched_racers) do |list|
        race.race_participations.create(:racer => list.text)
        visit "/races/#{id}/edit"
      end
    end
    
    para(link "back", :click => "/races/#{id}/ready")
  end
end
