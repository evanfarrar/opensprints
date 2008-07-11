module InterfaceWidgets
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
end
