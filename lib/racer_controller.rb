module RacerHelper
end

class RacerController < Shoes::Main
  include RacerHelper
  url '/racers', :list
  url '/racers/(\d+)/(\d+)', :edit
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

  def edit(id, tournament_id)
    racer = Racer.get(id)
    tournament = Tournament.get(tournament_id)
    tournament_participation = TournamentParticipation.first(:tournament => tournament, :racer => racer)||TournamentParticipation.create(:racer => racer, :tournament => tournament)
    layout
    @center.clear {
      container
      stack{
        flow {
          para "Name:"
          @e = edit_line(racer.name) do |edit|
            racer.name = edit.text
          end
        }
        separator_line
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
        separator_line
        flow { 
          c = check
          c.click { |c| tournament_participation.eliminated = c.checked? }
          c.checked = tournament_participation.eliminated
          para "Eliminated?"
        }
        
        flow {
          button "Save" do
            if((tournament.racers-[racer]).any? { |r| racer.name == r.name })
              alert("Racer is already in this event.")
            elsif old_racer = Racer.first(:name => racer.name, :id.not => racer.id)
              TournamentParticipation.create(:racer => racer, :tournament => tournament)
              old_racer.save
              old_racer.categorizations.destroy!
              @checkboxes.each do |cb, category|
                old_racer.categorizations.create(:category => category) if cb.checked?
              end
              if Racer.get(racer.id).name.blank? && racer.name.blank?
                TournamentParticipation.all(:racer => racer)
                racer.destroy
              end
              visit session[:referrer].pop||'/racers'
            else
              racer.save
              tournament_participation.save
              racer.categorizations.destroy!
              @checkboxes.each do |cb, category|
                racer.categorizations.create(:category => category) if cb.checked?
              end
              if Racer.get(racer.id).name.blank? && racer.name.blank?
                racer.destroy
              end
              visit session[:referrer].pop||'/racers'
            end
          end
          button "Cancel" do
            racer.destroy if Racer.get(racer.id).try(:name).blank?
            TournamentParticipation.all.each{ |tp| tp.destroy if tp.racer.nil? }
            visit session[:referrer].pop||'/racers'
          end
        }
      }
    }
    timer(0.01) { @e.focus }
  end

  def new
    racer = Racer.create
    visit "/racers/#{racer.id}"
  end

  def new_in_tournament(tournament_id)
    racer = Racer.create
    visit "/racers/#{racer.id}/#{tournament_id}"
  end

end
