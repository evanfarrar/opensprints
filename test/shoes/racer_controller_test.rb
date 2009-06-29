class ShoesTest < Shoes
  url '/', :index
  def index
    stack {
      background white
      background black(0.1)
      flow {
        banner "Opensprints GUI Tests"
      }
      stack {
        para(link("Racer Test", :click => '/racer_test'))
      }
      $update = flow{}
    }
  end

  def racer_test
    @r1 = Racer.create(:name => "Evan")
alert @r1.id
    visit "/racers/#{@r1.id}"
  end


end
Shoes.app
