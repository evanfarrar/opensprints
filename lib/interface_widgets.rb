class Shoes::DeleteRacer < Shoes::Widget
  def initialize(racer)
    image(20, 20, {:top => 8, :left => 350}) do
      delete_button 
      click do
        @tournament.racers.delete(racer)
        @racer_list.clear { list_racers }
      end
    end
  end
end

class Shoes::DeleteRace < Shoes::Widget
  def initialize(race)
    image(20, 20, {:top => 8, :left => 250}) do
      delete_button
      click do
        @tournament.matches.delete(race)
        @matches.clear { list_matches }
      end
    end
  end
end


class Shoes::DeleteButton < Shoes::Widget
  def initialize
    fill red
    rect(:top => 0, :left => 0, :height => 15, :width => 15)
    line(3,3,13,13)
    line(13,3,3,13)
  end
end


class Shoes::CreateRacer < Shoes::Widget
  def initialize
    image(20, 20, {:top => 8, :left => 115}) do
      add_button
      click do
        add_racer @racer_name.text
      end
    end
  end
end

class Shoes::AddToRace < Shoes::Widget
  def initialize(racer)
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
end


class Shoes::AddButton < Shoes::Widget
  def initialize
    fill red
    rect(:top => 0, :left => 0, :height => 15, :width => 15)
    line(8,3,8,13)
    line(3,8,13,8)
  end
end

class Shoes::Redblue < Shoes::Widget
  def initialize(race)
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
