require 'yaml'

begin
  options = YAML::load(File.read('conf.yml'))
rescue
  alert "You must write a conf.yml. See sample in conf-sample.yml"
end
Infinity = 1/0.0
require 'lib/units/base'
require 'lib/units/standard'
SENSOR_LOCATION = options['sensor']['device']
RACE_DISTANCE = options['race_distance'].meters.to_km
$ROLLER_CIRCUMFERENCE = options['roller_circumference'].mm.to_km
TITLE = options['title']
require 'lib/racer'
require 'lib/race'
require 'lib/interface_widgets'
require 'lib/tournament'
require 'lib/secsy_time'
require "lib/sensors/#{options['sensor']['type']}_sensor"
require 'lib/race_presenter'

UNIT_SYSTEM = (options['units'] == 'standard') ? :mph : :kmph

Shoes.app :title => TITLE, :width => 800, :height => 600 do
  background white
  extend InterfaceWidgets
  extend RacePresenterMod
  @tournament = Tournament.new(RACE_DISTANCE)

  def list_racers
    flow do 
      flow(:width => 115) { para 'Name' }
      flow(:width => 50)  { para 'Wins' }
      flow(:width => 25)  { para 'Best' }
    end
    @tournament.racers.each do |racer|
      flow do 
        border black
        flow(:width => 115) { para racer.name }
        flow(:width => 50)  { para racer.wins, " / ", racer.races }
        flow(:width => 25)  { para racer.best_time, "s" unless racer.best_time == Infinity }
        add_to_race racer
        delete_racer racer
      end
    end
  end

  def post_race
    relist_tournament
  end

  def tournament_record(race)
    @tournament.record(race)
  end

  def list_matches
    border black
    title "Matches"
    @tournament.matches.each do |match|
      flow(:margin => 5) do 
        background lightgrey
        border black
        flow(:width => 180) do
          if match.racers.length == 1
            para match.racers.first.name
          else
            para span(match.blue_racer.name, :stroke => blue),
                 " vs ",
                 span(match.red_racer.name, :stroke => red)
          end
        end
        button("race")do
          race_window(match, RACE_DISTANCE, SENSOR_LOCATION, TITLE)
        end
        redblue(match)
        delete_race(match)
      end
    end      
  end

  def add_racer(name)
    duped = @tournament.racers.any? do |racer|
      racer.name == name
    end
    if !duped && name!='enter name'
      @tournament.racers << Racer.new(:name => name, :units => UNIT_SYSTEM)
      relist_tournament
    end
  end

  def relist_tournament
    @matches.clear {list_matches}
    @racer_list.clear {list_racers}
  end

  stack(:width => 380, :margin => 5) do
    border black
    title "Racers"
    @racer_list = stack { list_racers }
    flow do
      @racer_name = edit_line "enter name"
      create_racer
    end
  end

  @matches = stack(:width => 290, :margin => 5) do
    list_matches
  end

  button "autofill matches" do
    @tournament.autofill_matches
    relist_tournament
  end

  button "save" do
    File.open(ask_save_file, 'w+') { |f| f << @tournament.to_yaml }
  end

  button "open" do
    @tournament = YAML::load(File.open(ask_open_file))
    relist_tournament
  end
end
