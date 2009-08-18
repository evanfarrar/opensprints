module TournamentHelper
  def stats_table(label,racers)
    if racers.any?
      stack do
        background gray(0.2, 0.5)

        flow(:height => 52) { title label+':', :font => "Bold", :stroke => black }

        flow(:height => 20) do
          stack(:width => 0.4) { para 'NAME', :stroke => black }
          stack(:width => 0.2) { para 'WINS/LOSSES', :font => "Helvetica Neue", :stroke => black }
          stack(:width => 0.2) { para 'BEST', :font => "Helvetica Neue", :stroke => black }
          stack(:width => 0.2) { para 'PLACE', :font => "Helvetica Neue", :stroke => black }
        end
        stack(:scroll => false) do
          racers.each do |racer|
            stack do
              flow do
                stack(:width => 0.4) { inscription racer.racer.name, :stroke => black }
                stack(:width => 0.2) { inscription "", :stroke => black }
                stack(:width => 0.18) { inscription racer.best_time, :stroke => black }
                flow(:width => 0.22) { inscription '', :stroke => black }
              end
            end
          end
        end
      end
    end
  end

end

class TournamentController < Shoes::Main
  include TournamentHelper
  url '/tournaments', :list
  url '/tournaments/(\d+)', :edit
  url '/tournaments/(\d+)/stats', :stats
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
    para(link "stats", :click => "/tournaments/#{tournament.id}/stats")
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
        stack {
          tournament.races.each{|r|
            para(link r.racers.join(' vs '), :click => "/races/#{r.id}/ready")
          }
        }
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

  def stats(id)
    nav
    tournament = Tournament.get(id)
    para(link "back", :click => "/tournaments/#{id}")
    racers = tournament.tournament_participations.to_a
    @stats = flow do
      if racers.any?
        stats_table("OVERALL",racers.shift(9))
      end
    end
    every(10) do
      if racers.any?
        @stats.clear do
          stats_table("OVERALL",racers.shift(9))
        end
      else
        timer(10) { visit "/tournaments/#{id}/stats" }
      end
    end
  end
end
