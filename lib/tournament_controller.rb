class TournamentController < Shoes::Main
  url '/tournaments', :list
  url '/tournaments/(\d+)', :edit
  url '/tournaments/new', :new

  def list
    nav
    stack do
      para(link "new tournament", :click => "/tournaments/new")
      Tournament.all.each {|tournament|
        flow {
          para(link(tournament.name,:click => "/tournaments/#{tournament.id}"))
        }
      }
    end
  end

  def new
    nav
    tournament = Tournament.new
    form(tournament)
  end

  def edit(id)
    nav
    tournament = Tournament.get(id)
    form(tournament)
  end

  def form(tournament)
    stack{
      flow {
        para "name:"
        edit_line(tournament.name) do |edit|
          tournament.name = edit.text
        end
      }
      flow {
        para "racers:"
        stack {
          racers = stack { para tournament.tournament_participations.map(&:racer).join(', ') }
          list_box(:items => Racer.all.to_a) do |list|
            tournament.tournament_participations.build(:racer => list.text)
            tournament.save
            visit "/tournaments/#{tournament.id}"
          end
        }
        para "races:"
        stack { tournament.races.each{|r| para r.racers.join(' vs ')} }
      }
      button "Autofill" do
        tournament.autofill
        tournament.save
        visit "/tournaments/#{tournament.id}"
      end
      button "Save & close" do
        tournament.save
        visit '/tournaments'
      end
    }

  end
end
