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
        button("new racer") { visit "/racers/new" }
        Racer.all.each {|r|
          para(link(r.name,:click => "/racers/#{r.id}"))
        }
      end
    }
  end

  def edit(id)
    racer = Racer.get(id)
    layout
    @center.clear {
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
            stack(:width => 0.5) {
              racer.categorizations.each { |categorization|
                flow {
                  flow(:width => 0.6, :margin_top => 8) { para categorization.category.name }
                  flow(:width => 0.1)
                  flow(:width => 0.3) {
                    button("delete") {
                      categorization.destroy
                      visit "/racers/#{id}"              
                    }
                  }
                }
              }
            }
            list_box(:items => Category.all.to_a - racer.categories) do |list|
              racer.save
              racer.categorizations.create(:category => list.text)
              visit "/racers/#{id}"              
            end
          }
        }
        button "Save" do
          racer.name = "Racer #{racer.id}" if racer.name.blank?
          racer.save
          visit session[:referrer].pop||'/racers'
        end
      }
    }
  end

  def new
    racer = Racer.create
    visit "/racers/#{racer.id}"
  end

  def new_in_tournament(tournament_id)
    racer = Racer.create
    TournamentParticipation.create(:racer => racer, :tournament_id => tournament_id)
    visit "/racers/#{racer.id}"
  end

end
