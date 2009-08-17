class RaceController < Shoes::Main
  url '/races/(\d+)/ready', :ready
  url '/races/(\d+)/countdown', :countdown
  url '/races/(\d+)', :show
  url '/races/(\d+)/winner', :winner


  def ready(id)
    nav
    race = Race.get(id)
    title race.racers.join(' vs ')
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
          banner "GO!!!", :font => "140px", :stroke => white, :align => 'center'
        end
      when 1
        SENSOR.start
        @counter.clear do
          background(rgb(200,0,0, 0.7))
          background(gradient(rgb(0,0,200, 0.7),rgb(200,0,0, 0.7), :angle => 90))
          banner 4-count, :font => "140px", :stroke => white, :align => 'center'
        end
      when 0..4
        @counter.clear do
          background(rgb(200,0,0, 0.7))
          banner 4-count, :font => "140px", :stroke => white, :align => 'center'
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
      rp.finish_time = rand(2)
      rp.save
    }
    para "Hooray!"
    visit "/races/#{id}/winner"
  end

  def winner(id)
    race = Race.get(id)
    winner = race.winner
    background eval(winner.color+"(0.6)")
    nav
    stack(:top => 40, :left => 0) do
      banner "WINNER IS "+winner.racer.name.upcase, :font => "Helvetica Neue Bold", :stroke => white, :align => "center"
    end
  end
end
