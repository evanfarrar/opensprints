class Main < Shoes
  url '/', :index

  def index
    para(link "racers", :click => "/racers")
    para(link "categories", :click => "/categories")
    para(link "tournaments", :click => "/tournaments")
  end

  def nav
    para(link "index", :click => "/")
  end
end
#YAY HAPPY FUN TIME UN-NAMESPACING
Kernel::Main = Main

require 'lib/setup.rb'
Racer.create(:name => "evan")
Racer.create(:name => "Alex")
Racer.create(:name => "luke")
Racer.create(:name => "jon")
Racer.create(:name => "evan2")
Racer.create(:name => "Alex2")
Racer.create(:name => "luke2")
Racer.create(:name => "jon2")
Racer.create(:name => "evan3")
Racer.create(:name => "Alex3")
Racer.create(:name => "luke3")
Racer.create(:name => "jon3")
Racer.create(:name => "evan4")
Racer.create(:name => "Alex4")
Racer.create(:name => "luke4")
Racer.create(:name => "jon4")
Racer.create(:name => "evan5")
Racer.create(:name => "Alex5")
Racer.create(:name => "luke5")
Racer.create(:name => "jon5")
Racer.create(:name => "evan6")
Racer.create(:name => "Alex6")
Racer.create(:name => "luke6")
Racer.create(:name => "jon6")
Category.create(:name => "Women")
Category.create(:name => "Men")
t = Tournament.create(:name => "December Series")
Racer.all.each{|r|
  t.tournament_participations.create(:racer => r)
}

Shoes.app
