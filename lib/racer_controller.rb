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
          para "Name:"
          edit_line(racer.name) do |edit|
            racer.name = edit.text
          end
        }
        flow {
          para "Assign to Categories:"
          stack {
            stack(:width => 0.5) {
              @checkboxes = Category.all.map do |category|
                flow { @c = check; para category.name }
                @c.checked = racer.categories.include?(category)
                [@c, category]
              end
            }
          }
        }
        flow {
          button "Save" do
            racer.save
            racer.categorizations.destroy!
            @checkboxes.each do |cb, category|
              racer.categorizations.create(:category => category) if cb.checked?
            end
            racer.destroy if Racer.get(racer.id).name.blank? && racer.name.blank?
            TournamentParticipation.all.each{ |tp| tp.destroy if tp.racer.nil? }
            visit session[:referrer].pop||'/racers'
          end
          button "Cancel" do
            racer.destroy if Racer.get(racer.id).try(:name).blank?
            TournamentParticipation.all.each{ |tp| tp.destroy if tp.racer.nil? }
            visit session[:referrer].pop||'/racers'
          end
        }
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
