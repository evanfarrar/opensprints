require 'lib/setup.rb'
Shoes.app(:title => TITLE, :width => 800, :height => 600) do
  def delete_racer(racer)
    image(20, 20, {:top => 8, :left => 350}) do
      delete_button 
      click do
        @tournament.racers.delete(racer)
        @racer_list.clear { list_racers }
      end
    end
  end

  def delete_race(race)
    image(20, 20, {:top => 8, :left => 250}) do
      delete_button
      click do
        @tournament.matches.delete(race)
        @matches.clear { list_matches }
      end
    end
  end

  def create_racer
    image(20, 20, {:top => 8, :left => 115}) do
      add_button
      click do
        add_racer @racer_name.text
      end
    end
  end

  def add_to_race(racer)
    image(20, 20, {:top => 8, :left => 325}) do
      add_button
      click do
        @tournament.add_racer(racer)

        @matches.clear do
          list_matches
        end
      end
    end
  end

  def delete_button
    fill red
    rect(:top => 0, :left => 0, :height => 15, :width => 15)
    line(3,3,13,13)
    line(13,3,3,13)
  end

  def add_button
    fill red
    rect(:top => 0, :left => 0, :height => 15, :width => 15)
    line(8,3,8,13)
    line(3,8,13,8)
  end

  def redblue(race)
    image(20, 20, {:top => 8, :left => 150}) do
      fill red
      rect(:top => 0, :left => 0, :height => 15, :width => 7)
      fill blue
      rect(:top => 0, :left => 7, :height => 15, :width => 7)
      click do
        race.flip
        @matches.clear { list_matches }
      end
    end 
  end

  background white
  @tournament = Tournament.new(RACE_DISTANCE)
 
  def list_racers
    flow do
      flow(:width => 115) { para 'Name' }
      flow(:width => 50) { para 'Wins' }
      flow(:width => 25) { para 'Best' }
    end
    @tournament.racers.each do |racer|
      flow do
        border black
        flow(:width => 115) { para racer.name }
        flow(:width => 50) { para racer.wins, " / ", racer.races }
        flow(:width => 25) { para racer.best_time, "s" unless racer.best_time == Infinity }
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
          race_window(match, RACE_DISTANCE, SENSOR, Shoes::TITLE)
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
      @racer_name = edit_line "enter name", :width => 110
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
