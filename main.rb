require 'lib/setup.rb'
load 'lib/race_window.rb'

Shoes.app(:height => 180, :width => 200,
          :resizable => false, :title => "OpenSprints") do
  extend RaceWindow
  subtitle "OpenSprints"
  stack do
    button("Configuration", :width => 200) do
      load 'lib/config_app.rb'
    end

    button("Race with Names", :width => 200) do
      race_window(Race.new(Racer.new(:name => ask("red?"), :units => UNIT_SYSTEM),
        Racer.new(:name => ask("blue?"), :units => UNIT_SYSTEM), RACE_DISTANCE))
    end

    button("Race a Tournament", :width => 200) do
      load 'lib/tournament_app.rb'
    end

    button("Just Race!", :width => 200) do
      load 'lib/race_app.rb'
    end
    
  end
end
