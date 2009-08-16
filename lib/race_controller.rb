class RaceController < Shoes::Main
  url '/races/(\d+)/ready', :ready
  url '/races/(\d+)', :show
  url '/races/(\d+)', :show


  def ready(id)
    nav
    race = Race.get(id)
    title race.racers.join(' vs ')
  end

  def countdown(id)
    
  end

  def show
    
  end
end
