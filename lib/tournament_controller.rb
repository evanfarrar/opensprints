module TournamentHelper
  def stats_table(label,racers)
    if racers.any?
      stack do
        container
        flow(:height => 52) { title label+':', :font => "Bold" }
        separator_line(80)
        flow(:height => 20) do
          stack(:width => 0.4) { para 'NAME' }
          stack(:width => 0.2) { para 'WINS/LOSSES' }
          stack(:width => 0.2) { para 'BEST' }
          stack(:width => 0.2) { para 'PLACE' }
        end
        separator_line(80)
        stack(:scroll => false) do
          racers.each do |racer|
            stack do
              flow do
                stack(:width => 0.4) { inscription racer.racer.name }
                stack(:width => 0.2) { inscription "" }
                stack(:width => 0.18) { inscription((("%.2f" % racer.best_time) if racer.best_time)) }
                flow(:width => 0.22) { inscription racer.rank }
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
  url '/tournaments/new', :new
 
  url '/tournaments/(\d+)/stats', :overall_stats
  url '/tournaments/(\d+)/stats/(\d+)', :overall_stats
  url '/tournaments/(\d+)/stats/category//(\d+)', :overall_stats
  url '/tournaments/(\d+)/stats/category/(\d+)/(\d+)', :category_stats

  def list
    layout(:menu)
    @center.clear {
      stack(:width => 0.5) do
        container
        button("new event") { visit "/tournaments/new" }
        Tournament.all.each {|tournament|
          flow(:width => 1.0, :margin_left => 20) {
            separator_line
          }
          flow(:width => 1.0, :margin_left => 20) {
            flow(:width => 0.6, :margin_top => 8) {
              para(link(tournament.name,:click => "/tournaments/#{tournament.id}"))
            }
            flow(:width => 0.1) { }
            flow(:width => 0.3) {
              delete_button { tournament.destroy; visit "/tournaments" }
            }
          }
        }
      end
    }
  end

  def new
    layout(:menu)
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
    tournament = Tournament.get(id)
    @title = tournament.name
    layout(:menu)
    small_logo
    session[:referrer] = []
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
              edit_button do
                session[:referrer].push(@center.app.location)
                visit "/racers/#{tp.racer.id}"
              end
              flow(:width => 15)
              delete_button do
                tp.destroy; visit "/tournaments/#{tournament.id}"
              end
            }
          }
        end
      }
      stack(:width => 1.0) {
        button("add a new racer") {
          session[:referrer].push(@center.app.location)
          visit("/racers/new/tournament/#{tournament.id}")
        }

      }
    }
    stack(:width => 0.1)
    stack(:width => 0.4, :height => @center.height-100) {
      container
      title "races:"
      stack(:height => @center.height-200, :scroll => true) {
        tournament.races.each{|race|
          flow {
            flow(:width => 0.6) {
              if race.unraced?
                para(race.racers.join(' vs '))
              else
                para(del(race.racers.join(' vs ')))
              end
            }
            flow(:width => 0.4) {
              button "RACE" do
                visit "/races/#{race.id}/ready"
              end
              delete_button { race.destroy; visit "/tournaments/#{tournament.id}" }
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

  def overall_stats(id, racers_offset=0)
    layout(:menu)
    racers_offset = racers_offset.to_i
    tournament = Tournament.get(id)
    racers = tournament.tournament_participations.sort_by{|tp|tp.best_time||Infinity}
    racers.shift(9*racers_offset)

    @nav.append {
      button("back to event") { visit "/tournaments/#{id}" }
      button("next") { visit "/tournaments/#{id}/stats/#{racers_offset+1}" }
      pause = button("pause")
      play = button("play")
      pause.click { @t.toggle; play.toggle; pause.toggle }
      play.click  { @t.toggle; play.toggle; pause.toggle }
      play.hide
    }
    @center.clear {
      if racers.any?
        @stats = flow do
           stats_table("OVERALL",racers.shift(9))
           @t = timer(5) { visit "/tournaments/#{id}/stats/#{racers_offset+1}" }
        end
      else# out of racers in overall
        visit "/tournaments/#{id}/stats/category/#{Category.next_after(nil)}/0" #try the next category
      end
    }
  end

  def category_stats(tournament_id,category_id,racers_offset=0)
    layout(:menu)
    racers_offset = racers_offset.to_i
    tournament = Tournament.get(tournament_id)
    category = Category.get(category_id)
    racers = TournamentParticipation.all(:tournament_id => tournament_id, "racer.categorizations.category_id" => category_id)
    racers = racers.sort_by{|tp|tp.best_time||Infinity}
    racers.shift(9*racers_offset)

    @nav.append {
      button("back to event") { visit "/tournaments/#{tournament_id}" }
      button("next") { visit "/tournaments/#{tournament_id}/stats/category/#{category_id}/#{racers_offset+1}" }
      pause = button("pause")
      play = button("play")
      pause.click { @t.toggle; play.toggle; pause.toggle }
      play.click  { @t.toggle; play.toggle; pause.toggle }
      play.hide
    }
    @center.clear {
      if racers.any?
        @stats = flow do
          stats_table(category.name,racers.shift(9))
          @t = timer(5) { visit "/tournaments/#{tournament_id}/stats/category/#{category_id}/#{racers_offset+1}" }
        end
      else# out of racers in category
        visit "/tournaments/#{tournament_id}/stats/category/#{Category.next_after(category)}/0" #try the next category
      end
    }
  end
end
