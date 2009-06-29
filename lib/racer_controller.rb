class RacerController < Shoes
  url '/racers', :list
  url '/racers/(\d+)', :racer

  def list
    $update.clear do
      stack do
        Racer.all.each {|r|
          flow {
            para r.name
          }
        }
      end
    end
  end

  def racer(id)
    @racer = Racer.find(id)
    $update.clear do
      stack do
        flow(:width => 0.5) {
          para(strong("name: "))
        }
        flow(:width => 0.5) {
          para(@racer.name)
        }
      end
    end
  end
end
