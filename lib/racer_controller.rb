module RacerHelper
end

class RacerController < Shoes::Main
  include RacerHelper
  url '/racers', :list
  url '/racers/(\d+)', :edit
  url '/racers/new', :new
  url '/racers/new/tournament/(\d+)', :new_in_tournament

  def list
    layout    
    @center.clear {
      stack do
        para(link "new racer", :click => "/racers/new")
        Racer.all.each {|r|
          para(link(r.name,:click => "/racers/#{r.id}"))
        }
      end
    }
  end

  def new
    layout
    @center.clear {
      racer = Racer.new
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
          visit referrer
        end
      }
    }
  end

  def new_in_tournament(tournament_id)
    layout
    @center.clear {
      racer = Racer.new
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
          TournamentParticipation.create(:racer => racer, :tournament_id => tournament_id)
          visit "/tournaments/#{tournament_id}"
        end
      }
    }
  end

  def edit(id)
    layout
    @center.clear {
      racer = Racer.get(id)
      racer_form(racer)
    }
  end
end
