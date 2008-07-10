module InterfaceWidgets
  def equis(racer)
    image(20, 20, {:top => 8, :left => 350}) do
      fill red
      rect(:top => 0, :left => 0, :height => 15, :width => 15)
      line(3,3,13,13)
      line(13,3,3,13)
      click do
        @tournament.racers.delete(racer)
        @racer_list.clear { list_racers }
      end
    end
  end
  def plus
    image(20, 20, {:top => 8, :left => 115}) do
      fill red
      rect(:top => 0, :left => 0, :height => 15, :width => 15)
      line(8,3,8,13)
      line(3,8,13,8)
      click do
        add_racer @racer_name.text
      end
    end
  end
end
