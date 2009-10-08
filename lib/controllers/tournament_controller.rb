module TournamentHelper
  def stats_table(label,racers)
    if racers.any?
      stack do
        container
        flow(:height => 52) { title label+':', :font => "Bold" }
        separator_line(80)
        flow(:height => 20) do
          stack(:width => 0.4) { para $i18n.name }
          stack(:width => 0.2) { para $i18n.losses }
          stack(:width => 0.2) { para $i18n.best }
          stack(:width => 0.2) { para $i18n.place }
        end
        separator_line(80)
        stack(:scroll => false) do
          racers.each do |racer|
            stack do
              flow do
                stack(:width => 0.4) { inscription racer.racer.name }
                stack(:width => 0.2) { inscription racer.losses }
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
        button($i18n.new_event) { visit "/tournaments/new" }
        Tournament.all.each {|tournament|
          flow(:width => 1.0, :margin_left => 20) {
            separator_line
          }
          flow(:width => 1.0, :margin_left => 20) {
            flow(:width => 0.6, :margin_top => 8) {
              para(link(tournament.name,:click => "/tournaments/#{tournament.pk}"))
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
      container
      tournament = Tournament.new
      flow {
        para $i18n.name
        edit_line(tournament.name) do |edit|
          tournament.name = edit.text
        end
      }
      button $i18n.save_and_continue do
        if tournament.name.blank?
          #FIXME: i18n 
          alert("Sorry, Tournament name can't be blank.")
        elsif Tournament.filter(:name => tournament.name).any?
          #FIXME: i18n 
          alert("Sorry, Tournament name is already taken.")
        else
          tournament.save
          visit "/tournaments/#{tournament.pk}"
        end
      end
      button $i18n.cancel do
        visit "/tournaments"
      end
    }
  end

  def edit(id)
    tournament = Tournament[id]
    # TODO: optimize
    Race.filter(:tournament_id => id).all.each { |r| r.destroy if(r.racers.length == 0) }
    # TODO: optimize
    tournament.tournament_participations.each { |tp| tp.destroy if(tp.racer.nil?||tp.racer.name.blank?) }
    tournament = Tournament[id]
    @title = tournament.name
    layout(:menu)
    small_logo
    session[:referrer] = []
    @nav.append {
      button("stats") { visit "/tournaments/#{tournament.pk}/stats" }
    }
    @center.clear {
      form(tournament)
    }

  end

  def form(tournament)
    if(session[:category] && (session[:category] != $i18n.all_categories))
      #TODO optimize and use Sequel
      tournament_participations = tournament.tournament_participations.select{ |tp|
        tp.racer.categorizations.map(&:category).include?(session[:category])
      }
    else
      tournament_participations = tournament.tournament_participations
    end

    case session[:order_by]
      when $i18n.rank
        tournament_participations = tournament_participations.sort_by(&:rank)
      when $i18n.name
        tournament_participations = tournament_participations.sort_by{|tp|tp.racer.name.downcase}
    end
    races = tournament.races
    session[:hide_finished] = true if session[:hide_finished].nil?
    if session[:hide_finished]
      tournament_participations.reject! {|tp| tp.eliminated }
      races.reject! { |r| r.raced }
    end
        
    stack(:width => 0.4, :height => 1.0) {
      container
      #TODO i18n
      stack(:height => 0.12) { subtitle "racers:" }
      racers = stack(:height => 0.80, :scroll => true){ 
        tournament_participations.each do |tp|
          flow {
            flow(:width => 0.6) {
              tp.eliminated ? para(del(tp.racer.name)) : para(tp.racer.name) 
            }
            flow(:width => 0.3) {
              flow(:width => 0.8) {
                edit_button do
                  session[:referrer].push(@center.app.location)
                  visit "/racers/#{tp.racer.pk}/#{tp.tournament.pk}"
                end
              }
              flow(:width => 0.2) {
                delete_button do
                  if tp.race_participations.any?
                    tp.eliminate
                  else
                    tp.destroy
                  end
                  visit "/tournaments/#{tournament.pk}"
                end
              }
            }
          }
        end
      }
      stack(:width => 1.0, :height => 0.08) {
        button($i18n.add_a_new_racer) {
          session[:referrer].push(@center.app.location)
          visit("/racers/new/tournament/#{tournament.pk}")
        }
      }
    }
    stack(:width => 0.05)
    stack(:width => 0.55, :height => 1.0) {
      container
      #TODO i18n
      stack(:height => 0.12) { subtitle "races:" }
      stack(:height => 0.8, :scroll => true) {
        races.each{|race|
          flow {
            flow(:width => 0.6) {
              if race.unraced?
                para(race.racers.join(' vs '))
              else
                para(del(race.racers.join(' vs ')))
              end
            }
            flow(:width => 0.35) {
              flow(:width => 0.8){
                if race.raced
                  button "RESULTS" do
                    visit "/races/#{race.pk}/winner"
                  end
                else
                  button $i18n.race do
                    visit "/races/#{race.pk}/ready"
                  end
                end
              }
              flow(:width => 0.2){
                delete_button { race.destroy; visit "/tournaments/#{tournament.pk}" }
              }
            }
          }
        }
      }
      stack(:width => 1.0, :height => 0.08) {
        button($i18n.add_a_new_race) {
          session[:referrer].push(@center.app.location)
          visit "/races/new/tournament/#{tournament.pk}"
        }
      }
      
    }
    @left.clear do
      left_button $i18n.autofill do
        if(session[:category] && (session[:category] != $i18n.all_categories))
          #TODO optimize and use Sequel
          racers = tournament.tournament_participations.select{ |tp|
            !tp.eliminated && tp.racer.categorizations.map(&:category).include?(session[:category])
          }
          tournament.autofill(racers.map(&:racer)-tournament.matched_racers)
        else
          tournament.autofill
        end
        tournament.save
        visit "/tournaments/#{tournament.pk}"
      end
      left_button $i18n.new_round do
        n = ask($i18n.how_many_should_advance)
        unless n.nil?
          tournament_participations.sort_by{ |tp|
            tp.rank
          }[n.to_i..-1].each{ |tp| tp.update(:eliminated => true) }
          tournament.save
          visit "/tournaments/#{tournament.pk}"
        end
      end
      category = session[:category]
      order_by = session[:order_by]
      hide_finished = session[:hide_finished]
      categories = [$i18n.all_categories]+Category.all.to_a
      inscription "Filter by Category:", :margin => [0,30,0,0]
      list_box(:width => 1.0, :choose => category, :items => categories) do |list|
        session[:category] = list.text
        visit "/tournaments/#{tournament.pk}" if category != session[:category]
      end
      inscription "Order Racers:", :margin => [0,30,0,0]
      list_box(:width => 1.0, :choose => order_by, :items => [$i18n.name,$i18n.best_time]) do |list|
        session[:order_by] = list.text
        visit "/tournaments/#{tournament.pk}" if order_by != session[:order_by]
      end
      if session[:hide_finished]
        left_button $i18n.show_finished do
          session[:hide_finished] =  false
          visit "/tournaments/#{tournament.pk}" if hide_finished != session[:hide_finished]
        end
      else
        left_button $i18n.hide_finished do
          session[:hide_finished] =  true
          visit "/tournaments/#{tournament.pk}" if hide_finished != session[:hide_finished]
        end
      end
    end
  end

  def overall_stats(id, racers_offset=0)
    layout(:menu)
    racers_offset = racers_offset.to_i
    tournament = Tournament[id]
    racers = tournament.tournament_participations.sort_by{|tp|[(tp.best_time||Infinity)]}
    racers.shift(9*racers_offset)

    @nav.clear {
      button($i18n.back_to_event) { visit "/tournaments/#{id}" }
      button($i18n.next) { visit "/tournaments/#{id}/stats/#{racers_offset+1}" }
      pause = button($i18n.pause)
      play = button($i18n.play)
      pause.click { @t.toggle; play.toggle; pause.toggle }
      play.click  { @t.toggle; play.toggle; pause.toggle }
      play.hide
    }
    @center.clear {
      if racers.any?
        @stats = flow do
           stats_table($i18n.overall,racers.shift(9))
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
    tournament = Tournament[tournament_id]
    category = Category[category_id]
    #TODO optimize
    racers = TournamentParticipation.filter(:tournament_id => tournament_id).all.select{|tp|tp.racer.categorizations.map(&:category).include? category}
    racers = racers.sort_by{|tp|[tp.best_time||Infinity]}
    racers.shift(9*racers_offset)

    @nav.clear {
      button($i18n.back_to_event) { visit "/tournaments/#{tournament_id}" }
      button($i18n.next) { visit "/tournaments/#{tournament_id}/stats/category/#{category_id}/#{racers_offset+1}" }
      pause = button($i18n.pause)
      play = button($i18n.play)
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
