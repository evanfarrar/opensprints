module RaceHelper
  def count_text(text)
    banner text, :font => "140px", :align => 'center'
  end
end

class RaceController < Shoes::Main
  include RaceHelper
  url '/races/(\d+)/ready', :ready
  url '/races/(\d+)/countdown', :countdown
  url '/races/(\d+)', :show
  url '/races/(\d+)/winner', :winner
  url '/races/(\d+)/edit', :edit
  url '/races/new/tournament/(\d+)', :new_in_tournament


  def ready(id)
    layout
    race = Race.get(id)
    @nav.clear {
      button("Start") { visit "/races/#{id}/countdown" }
      button("Edit Race") { session[:referrer].push(@center.app.location); visit "/races/#{id}/edit" }
      if next_race = race.next_race
         button("Skip to Next Race") { visit "/races/#{next_race.id}/ready" }
      end
      button("New Race") { visit "/races/new" }
      if race.tournament
        button("back to event") { visit "/tournament/#{race.tournament.id}" }
      end
    }
    @center.clear {
      race = Race.get(id)

      stack {
        race.names_to_colors.each {|word,color|
          subtitle(
            word.upcase,
            :stroke => eval(color),
            :align => 'center',:margin => [0]*4)
        }
        if next_race = race.next_race
          flow {
            para("next race: ",next_race.racers.join(", "))
          }
        end
      }
    }
    
  end

  def countdown(id)
    layout
    race = Race.get(id)
    @nav.clear {
      button("Stop Countdown") { visit "/races/#{id}/ready" }
    }
    @timer = animate(1) { |count|
      case count
      when 4
        @center.clear do
          container
          count_text("GO!!!")
        end
      when 1
        SENSOR.start
        @center.clear do
          container
          count_text(4-count)
        end
      when 0..4
        @center.clear do
          container
          count_text(4-count)
        end
      else
        @timer.stop
        visit "/races/#{id}"
      end
    }
  end

  def show(id)
    layout
    small_logo
    race = Race.get(id)
    @nav.clear {
      button("Call It") {
        @race_animation.stop
        SENSOR.stop
        race.raced = true
        race.save
        visit "/races/#{id}/winner"
      }
      button("Redo") {
        @race_animation.stop
        SENSOR.stop
        visit "/races/#{id}/ready"
      }
    }
    @left.clear { 
      stack do # start progress_bars
        race.race_participations.each_with_index do |racer,i|
          stack(:width => 1.0) {
            background(eval(racer.color), :width => 1.0, :height => 80)
            subtitle(" ", :margin => [0]*4).displace(0,-10)
            subtitle(" ",:margin => [0]*4).displace(0,-28)
          }
        end
      end # end progress_bars
    }
    @right.clear { 
          stack do # start progress_bars
            race.race_participations.each_with_index do |racer,i|
              flow {
                stack(:width => 1.0) {
                  background("#e4e5e6", :width => 1.0, :height => 80)
                  subtitle(" ", :margin => [0]*4).displace(0,-10)
                  subtitle(" ",:margin => [0]*4).displace(0,-28)
                }
              }
            end
          end # end progress_bars
    }
    stroke red
    line(@right.left, 0, @right.left, HEIGHT)
    @race_animation = animate(14) do
      if race.finished?
        @race_animation.stop
        SENSOR.stop
        race.raced = true
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
          progress_bars = stack do # start progress_bars
            race.race_participations.each_with_index do |racer,i|
              flow {
                stack(:width => 1.0) {
                  background("#e4e5e6", :width => 1.0, :height => 80)
                  background(eval(racer.color), :width => racer.percent_complete, :height => 80)
                  subtitle(racer.racer.name,":", :stroke => white, :margin => [0]*4).displace(0,-10)
                  subtitle(racer.speed(racer.finish_time||SENSOR.time),"mph", :stroke => white, :margin => [0]*4).displace(0,-28)
                }
              }
            end
          end # end progress_bars
        end
      end
    end
  end

  def winner(id)
    race = Race.get(id)
    winner = race.winner
    layout
    @nav.append {
      button("back to event") { visit "/tournaments/#{race.tournament_id}" }
    }
    @center.clear {
      background eval(winner.color+"(0.6)")
      stack(:top => 40, :left => 0) do
        banner "WINNER IS "+winner.racer.name.upcase, :font => "Bold", :stroke => white, :align => "center"
        race.race_participations.each{|r|
          if r.finish_time
            subtitle("#{r.racer.name}: #{"%.2f" % r.finish_time} seconds", :stroke => white)
          else
            subtitle("#{r.racer.name}: DNF", :stroke => white)
          end
        }
        if next_race = race.next_race
          button("next race: #{next_race.racers.join(", ")}") { visit "/races/#{next_race.id}/ready" }
        end
      end
    }
  end

  def edit(id)
    race = Race.get(id)
    layout
    @center.clear {
      stack do
        race.race_participations.each do |race_participation|
          flow(:height => 70, :width => 1.0) do
            border eval(race_participation.color), :strokewidth => 4
            subtitle race_participation.racer.name
            
            para( "move to:")
            list_box(:items => race.race_participations.map(&:color) - [race_participation.color]) do |list|
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
            delete_button {
              race_participation.destroy
              visit "/races/#{id}/edit"
            }
          end
        end
        flow {
          if($BIKES.length > race.race_participations.count)
            para "add a racer:"
            list_box(:items => race.tournament.unmatched_racers) do |list|
              race.race_participations.create(:racer => list.text)
              visit "/races/#{id}/edit"
            end
          end
        }
        stack {
          # TODO: this should clearly indicate which choice the user has just come from. "Save and go BACK to tournament"
          button("save & start race") { visit "/races/#{id}/ready" }
          (button("save & return to event") { visit "/tournaments/#{race.tournament_id}" }) if race.tournament_id
        }
      end
      
    }
  end

  def new_in_tournament(tournament_id)
    race = Race.create(:tournament_id => tournament_id)
    visit "/races/#{race.id}/edit"
  end
end
