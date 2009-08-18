module RaceHelper
  # Returns an array of the format:
  # [["joe", "red"], ["vs.", "white],["nick","blue"]]
  def names_to_colors(racers)
    racers.join(" vs. ").split(' ').zip(BIKES.join(" white ").split(' '))
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


  def ready(id)
    nav
    race = Race.get(id)

    stack {
      names_to_colors(race.racers).each {|word,color|
        subtitle(word.upcase,:font => "Helvetica Neue Bold ", :stroke => eval(color), :align => 'center',:margin => [0]*4)
      }
    }

    para(link "Start", :click => "/races/#{id}/countdown")
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
    race.race_participations.each{|rp|
      rp.finish_time = rand(5)
      rp.save
    }
    para "Hooray!"
    SENSOR.stop
    visit "/races/#{id}/winner"
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
        subtitle("#{r.racer.name}: #{r.finish_time} seconds", :stroke => white)
      }
    end
  end
end
