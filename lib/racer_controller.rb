class RacerController < Main
  url '/racers', :list
  url '/racers/(\d+)', :show
  url '/racers/new', :new

  def list
    nav
    stack do
      para(link "new racer", :click => "/racers/new")
      Racer.all.each {|r|
        flow {
          para r.name
        }
      }
    end
  end

  def new
    nav
    racer_attrs = {}
    stack{
      flow {
        para "name:"
        edit_line('') do |edit|
          racer_attrs[:name] = edit.text
        end
      }
      button "Create" do
        Racer.create(racer_attrs)
        visit '/racers'
      end
    }
  end

  def show(id)
    nav
    racer = Racer.find(id)
    stack do
      flow(:width => 0.5) {
        para(strong("name: "))
      }
      flow(:width => 0.5) {
        para(racer.name)
      }
    end
  end
end
