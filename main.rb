require 'lib/setup.rb'

Shoes.app(:height => 230, :width => 240,
          :resizable => false, :title => "OpenSprints") do
  extend RaceWindow
  image "http://forum.teambeerd.com/opensprints_logo_tiny.png"
  subtitle "OpenSprints"
  stack do
    button("Configuration", :width => 240) do
      load 'lib/config_app.rb'
    end

    button("Race a Tournament", :width => 240) do
      load 'lib/tournament_app.rb'
    end

    button("Race with Names", :width => 240) do
      racers = BIKES.map{|b| Racer.new(:name => ask(b), :units => UNIT_SYSTEM)}
      race_window(Race.new(racers, $RACE_DISTANCE))
    end

    button("Just Race!", :width => 240) do
      racers = BIKES.map{|b| Racer.new(:name => b, :units => UNIT_SYSTEM)}
      race_window(Race.new(racers, $RACE_DISTANCE))
    end
    
    inscription link "www.opensprints.org", :click =>"http://opensprints.org"
  end
end
