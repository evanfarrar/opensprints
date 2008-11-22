Shoes.app do
  def stat_table(racers)
    flow do
      flow(:width => 50)  {   }
      flow(:width => 150) { tagline "name" }
      flow(:width => 250) { tagline "time" }
      flow(:width => 150) { tagline "wins" }
      flow(:width => 150) { tagline "losses" }
    end
    racers.each do |r|
      flow do
        flow(:width => 50)  { subtitle r[1] }
        flow(:width => 150) { subtitle r[0].name }
        flow(:width => 250) { subtitle r[0].best_time }
        flow(:width => 150) { subtitle r[0].wins }
        flow(:width => 150) { subtitle r[0].losses }
      end
    end
  
  end

  def rescreen
    @screens = []
    women = YAML::load(File.open(@women_file))
    men = YAML::load(File.open(@men_file))
    ranked_racers = men.racers.sort_by{|r|r.best_time}
    ranked_racers= ranked_racers.zip((1..ranked_racers.length).to_a)

    ranked_racers.each_slice(10) do |racers|
      @screens << lambda do
        stack do
          subtitle "Men", :align => "center" 
          stat_table(racers)
        end
      end
    end
    @screens << lambda { image @image_file } if @image_file
    women = YAML::load(File.open(@men_file))
    ranked_racers = women.racers.sort_by{|r|r.best_time}
    ranked_racers= ranked_racers.zip((1..ranked_racers.length).to_a)

    ranked_racers.each_slice(10) do |racers|
      @screens << lambda do
        stack do
          subtitle "Women", :align => "center" 
          stat_table(racers)
        end
      end
    end
    @screens << lambda { image @image_file; rescreen }
  end

  button "men" do
    @men_file = ask_open_file
  end
  button "women" do
    @women_file = ask_open_file
  end
  button "sponsors" do
    @image_file = ask_open_file
  end

  button "message" do
    @message = ask("message?")
  end

  button "start" do
    rescreen
    every(5) do |count|
      app.clear
      @screens[count % @screens.length].call()
    end
  end

end
