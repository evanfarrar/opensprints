require 'lib/setup.rb'

Shoes.app(:title => TITLE, :width => 800, :height => 600) do
  extend RaceWindow

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
    image(20, 20, {:top => 8, :left => 365}) do
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
    image(20, 20, {:top => 8, :left => 340}) do
      fill eval(BIKES[0])
      rect(:top => 0, :left => 0, :height => 15, :width => 7)
      fill eval(BIKES[1])
      rect(:top => 0, :left => 7, :height => 15, :width => 7)
      click do
        race.flip
        @matches.clear { list_matches }
      end
    end 
  end

  background black
  @tournament = Tournament.new($RACE_DISTANCE)
 
  def list_racers
    flow do
      flow(:width => 115) { para 'Name', :stroke => ivory }
      flow(:width => 50) { para 'Wins', :stroke => ivory }
      flow(:width => 25) { para 'Best', :stroke => ivory }
    end
    @tournament.racers.compact.each do |racer|
      flow do
        border gray(0.65) 
        flow(:width => 115) { para racer.name, :stroke => ivory }
        flow(:width => 50) { para racer.wins, " / ", racer.races, :stroke => ivory }
        flow(:width => 25) { para racer.best_time, "s", :stroke => ivory unless racer.best_time == Infinity }
        add_to_race racer
        delete_racer racer
      end
    end
  end
 
  def post_race
    relist_tournament
  end
 
  def tournament_record(race)
    race.winner
    @tournament.record(race)
    relist_tournament
  end
 
  def list_matches
    background gray(0.10), :curve => 14
    border gray(0.65), :curve => 14, :strokewidth => 3
    title "Matches", :stroke => ivory
    @tournament.matches.each do |match|
      flow(:margin => 5) do
        background gray(0.3)
        border black
        flow(:width => 270) do
          # FIXME THIS IS HORRENDOUS
          para((span(match.racers[0].name+" ", :stroke => eval(BIKES[0])) if match.racers[0]),
               (span(match.racers[1].name+" ", :stroke => eval(BIKES[1])) if match.racers[1]),
               (span(match.racers[2].name+" ", :stroke => eval(BIKES[2])) if match.racers[2]),
               (span(match.racers[3].name+" ", :stroke => eval(BIKES[3])) if match.racers[3]),
               :weight => "ultrabold")
        end
        button("race")do
          race_window match, @tournament
        end
        redblue(match)
        delete_race(match)
      end
    end
  end
 
  def add_racer(name)
    duped = @tournament.racers.compact.any? do |racer|
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
 
  stack(:width => 380, :margin => 5, :curve => 14) do
    background gray(0.15), :curve => 14
    border gray(0.65), :curve => 14, :strokewidth => 3
    title "Racers", :stroke => ivory
    @racer_list = stack { list_racers }
    flow(:margin => 8) do
      @racer_name = edit_line "enter name", :width => 110
      create_racer
    end
  end
 
  @matches = stack(:width => 800 - gutter() - 380, :margin => 5, :curve => 14) do
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
