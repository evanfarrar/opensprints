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
load 'test/fixtures.rb'

Shoes.app
