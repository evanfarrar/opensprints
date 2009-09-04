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
                stack(:width => 0.18) { inscription((("%.2f" % racer.best_time) if racer.best_time), :stroke => black) }
                flow(:width => 0.22) { inscription racer.rank, :stroke => black }
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
  include RacerHelper
  url '/tournaments', :list
  url '/tournaments/(\d+)', :edit
  url '/tournaments/(\d+)/stats', :stats
  url '/tournaments/new', :new
 
  def list
    layout
    @center.clear {
      stack(:width => 0.5) do
        button("new tournament") { visit "/tournaments/new" }
        Tournament.all.each {|tournament|
          separator_line
          flow(:width => 1.0) {
            flow(:width => 0.6, :margin_top => 8) {
              para(link(tournament.name,:click => "/tournaments/#{tournament.id}"))
            }
            flow(:width => 0.1) { }
            flow(:width => 0.3) {
              button("delete") { tournament.destroy; visit "/tournaments" }
            }
          }
        }
      end
    }
  end

  def new
    layout
    @center.clear {
      tournament = Tournament.new
      flow {
        para "name:"
        edit_line(tournament.name) do |edit|
          tournament.name = edit.text
        end
      }
      button "Save & continue" do
        tournament.save
        visit "/tournaments/#{tournament.id}"
      end
    }
  end

  def edit(id)
    layout
    session[:referrer] = []
    tournament = Tournament.get(id)
    @nav.append {
      button("stats") { visit "/tournaments/#{tournament.id}/stats" }
    }
    @center.clear {
      form(tournament)
    }
  end

  def form(tournament)
    if(session[:category] && (session[:category] != "All Categories"))
      tournament_participations = tournament.tournament_participations.select{ |tp|
        tp.racer.categorizations.map(&:category).include?(session[:category])
      }
    else
      tournament_participations = tournament.tournament_participations
    end

    case session[:order_by]
      when "Best time"
        tournament_participations = tournament_participations.sort_by(&:rank)
      when "Name"
        tournament_participations = tournament_participations.sort_by{|tp|tp.racer.name.downcase}
    end
        
    stack(:width => 0.4, :height => @center.height-100) {
      container
      title "racers:"
      racers = stack(:height => @center.height-200, :scroll => true){ 
        tournament_participations.each do |tp|
          flow {
            flow(:width => 0.6) { para(tp.racer.name) }
            flow(:width => 0.3) {
              light_button("delete") do
                tp.destroy; visit "/tournaments/#{tournament.id}"
              end
            }
          }
        end
      }
      stack(:width => 1.0) {
        light_button("add a new racer") {
          session[:referrer].push(@center.app.location)
          visit("/racers/new/tournament/#{tournament.id}")
        }

      }
    }
    stack(:width => 0.4, :height => @center.height-100) {
      container
      title "races:"
      stack(:height => @center.height-200, :scroll => true) {
        tournament.races.each{|race|
          flow {
            flow(:width => 0.6) {
              para(
                if race.unraced?
                  link(race.racers.join(' vs '), :click => "/races/#{race.id}/ready")
                else
                  del(race.racers.join(' vs '))
                end)
            }
            flow(:width => 0.3) {
              light_button("delete") { race.destroy; visit "/tournaments/#{tournament.id}" }
            }
          }
        }
      }
      stack(:width => 1.0) {
        light_button("add a new race") {
          session[:referrer].push(@center.app.location)
          visit "/races/new/tournament/#{tournament.id}"
        }
      }
      
    }
    @left.clear do
      left_button "Autofill" do
        tournament.autofill
        tournament.save
        visit "/tournaments/#{tournament.id}"
      end
      category = session[:category]
      order_by = session[:order_by]
      categories = ["All Categories"]+Category.all.to_a
      para "category:"
      list_box(:width => 1.0, :choose => category, :items => categories) do |list|
        session[:category] = list.text
        visit "/tournaments/#{tournament.id}" if category != session[:category]
      end
      para "order:"
      list_box(:width => 1.0, :choose => order_by, :items => ["Name","Best time"]) do |list|
        session[:order_by] = list.text
        visit "/tournaments/#{tournament.id}" if order_by != session[:order_by]
      end
      
    end
  end

  def stats(id)
    layout
    @center.clear {
      tournament = Tournament.get(id)
      para(link "back", :click => "/tournaments/#{id}")
      racers = tournament.tournament_participations.sort_by{|tp|tp.best_time||Infinity}
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
    }
  end
end
