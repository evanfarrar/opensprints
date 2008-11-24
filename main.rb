require 'lib/setup.rb'
require 'lib/race_window.rb'

Shoes.app(:height => 210, :width => 200,
          :resizable => false, :title => "OpenSprints") do
  extend RaceWindow
  subtitle "OpenSprints"
  stack do
    button("Configuration", :width => 200) do
      load 'lib/config_app.rb'
    end

    button("Stats", :width => 200) do
      load 'lib/stats_app.rb'
    end

    button("Race a Tournament", :width => 200) do
      load 'lib/tournament_app.rb'
    end

    button("Race with Names", :width => 200) do
      racers = BIKES.map{|b| Racer.new(:name => ask(b), :units => UNIT_SYSTEM)}
      race_window(Race.new(racers, RACE_DISTANCE))
    end

    button("Just Race!", :width => 200) do
      load 'lib/race_app.rb'
    end
    
  end
end
