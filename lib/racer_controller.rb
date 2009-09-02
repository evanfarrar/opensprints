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
            stack {
              racer.categorizations.each { |categorization|
                flow {
                  para categorization.category.name
                  button("delete") {
                    categorization.destroy
                    visit "/racers/#{id}"              
                  }
                }
              }
            }
            list_box(:items => Category.all.to_a) do |list|
              racer.save
              racer.categorizations.create(:category => list.text)
              visit "/racers/#{id}"              
            end
          }
        }
        button "Save" do
          racer.save
          if defined?(@@referrer)&&@@referrer
            visit @@referrer
          else
            visit '/racers'
          end
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
    @@referrer ||= "/tournaments/#{tournament_id}"
    visit "/racers/#{racer.id}"
  end

end
