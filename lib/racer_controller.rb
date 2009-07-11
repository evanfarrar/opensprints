class RacerController < Shoes::Main
  url '/racers', :list
  url '/racers/(\d+)', :edit
  url '/racers/new', :new

  def list
    nav
    stack do
      para(link "new racer", :click => "/racers/new")
      Racer.all.each {|r|
        flow {
          para(link(r.name,:click => "/racers/#{r.id}"))
        }
      }
    end
  end

  def new
    nav
    racer = Racer.new
    form(racer)
  end

  def edit(id)
    nav
    racer = Racer.get(id)
    form(racer)
  end

  def form(racer)
    stack{
      flow {
        para "name:"
        edit_line(racer.name) do |edit|
          racer.name = edit.text
        end
      }
      flow {
        para "categories:"
        stack {
          categories = stack { para racer.categorizations.map(&:category).join(', ') }
          list_box(:items => Category.all.to_a) do |list|
            racer.categorizations.build(:category => list.text)
            categories.clear { para racer.categorizations.map(&:category).join(', ') }
          end
        }
      }
      button "Save" do
        racer.save
        visit '/racers'
      end
    }

  end
end
