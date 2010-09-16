class RaceController < Shoes::Main
  include RaceHelper
  url '/races/(\d+)/ready', :ready
  url '/races/(\d+)/countdown', :countdown
  url '/races/(\d+)', :show
  url '/races/(\d+)/winner', :winner
  url '/races/(\d+)/edit', :edit
  url '/races/new/tournament/(\d+)', :new_in_tournament
  audience_friendly_urls %r'^/races/(\d+)/ready$', %r'^/races/(\d+)/countdown$',
    %r'^/races/(\d+)$', %r'^/races/(\d+)/winner$'


  def ready(id)
    @title = $i18n.get_ready_to_race
    layout(:race)
    race = Race[id]
    @nav.clear {
      button("Start") { visit "/races/#{id}/countdown" }
      button($i18n.edit_race) { session[:referrer].push(@center.app.location); visit "/races/#{id}/edit" }
      if next_race = race.next_race
         button("Skip to Next Race") { visit "/races/#{next_race.pk}/ready" }
      end
      button($i18n.new_race) {
        visit "/races/new/tournament/#{race.tournament_id}"
      }
      if race.tournament
        button($i18n.back_to_event) { visit "/tournaments/#{race.tournament.pk}" }
      end
      if race.racers.length == 2
        swap_button(race,"/races/#{id}/ready")
      end
    }
    @center.clear {
      race_track(race)
      stack {
        if next_race = race.next_race
          flow {
            tagline("next race: ",next_race.racers.join(", "))
          }.displace(0,220)
        end
      }
    }
  end

  def countdown(id)
    race = Race[id]
    layout(:race)
    @nav.clear {
      button("Stop Countdown") { visit "/races/#{id}/ready" }
    }
    race_track(race)
    @countbox = flow(:attach => Window, :top => (HEIGHT/2 - 100), :left => (WIDTH/2 - 125), :width => 250, :height => 200) { }
    @timer = animate(1) { |count|
      case count
      when 4
        @countbox.clear do
          container
          count_text($i18n.go)
        end
      when 1
        SENSOR.start
        @countbox.clear do
          container
          count_text(4-count)
        end
      when 0..4
        @countbox.clear do
          container
          count_text(4-count)
        end
      else
        @timer.stop
        visit "/races/#{id}"
      end
    }
  end

  def show(id)
    layout(:race)
    small_logo
    race = Race[id]
    @nav.clear {
      button("Call It") {
        stop_save_and_show_winner(race, id)
      }
      button("Redo") {
        @race_animation.stop
        SENSOR.stop
        visit "/races/#{id}/ready"
      }
    }
    @race_animation = animate(7) do
      if race.finished?
        stop_save_and_show_winner(race, id)
      else
        @center.clear do
          race.race_participations.each_with_index do |racer,i|
            racer.ticks = SENSOR.racers[i].size
            if SENSOR.finish_times[i]
              racer.finish_time = SENSOR.finish_times[i] / 1000.0
            end
          end
          race_track(race, true)
        end
      end
    end
  end

  def winner(id)
    race = Race[id]
    winner = race.winner
    layout(:menu)
    @nav.append {
      button($i18n.back_to_event) { visit "/tournaments/#{race.tournament_id}" }
    }
    @center.clear {
      stack(:height => 1.0) do
        flow(:height => 0.1) { background eval(winner.color) }
        flow(:height => 0.4) {
          banner $i18n.winner(winner.racer.name), :font => "Bold", :align => "center"

        }
        flow(:height => 0.1) { background(eval(winner.color)) }
        stack(:height => 0.4) {
          standings = race.race_participations.sort_by { |racer| racer.finish_time||Infinity }
          standings.each_with_index {|r,i|
            flow {
              flow(:width => 0.3) { caption((i+1).ordinal) }
              flow(:width => 0.3) { caption(r.racer.name)  }
              flow(:width => 0.3) { 
                if r.finish_time
                  #TODO i18n
                  caption("#{"%.2f" % r.finish_time} seconds")
                else
                  #TODO i18n ?
                  caption("DNF")
                end

              }
            }
          }
          if next_race = race.next_race
            button("next race: #{next_race.racers.join(", ")}") { visit "/races/#{next_race.pk}/ready" }
          end
        }
      end
    }
  end

  def edit(id)
    race = Race[id]
    layout
    @center.clear {
      stack(:width => 0.2, :height => 0.8) {
        container
        if($BIKES.length > race.racers.length)
          #TODO i18n
          stack(:height => 0.1){ para "UNMATCHED:" }
          stack(:height => 0.79, :scroll => true){ 
            if session[:hide_finished]
              racers = race.tournament.never_raced_and_not_eliminated
            else
              racers = race.tournament.unmatched_racers
            end
            racers.each do |racer|
              flow {
                flow(:width => 0.6) { para(racer.name) }
                flow(:width => 0.3) {
                  image_button("media/add.png") do
                    RaceParticipation.create(:racer => racer, :race => race)
                    visit "/races/#{id}/edit"
                  end
                }
              }
            end
          }
          stack(:height => 0.1){ 
            (button("add racer") { visit "/racers/new/race/#{race.pk}" })
          }
        else
          stack(:height => 0.1){  }
          stack(:height => 0.89, :scroll => true){ para $i18n.no_more_racers_need_assignment }
        end
      }
      stack(:width => 0.1)
      stack(:width => 0.7, :height => @center.height-100) {
        flow(:height => @center.height-150){ 
          container
          case race.racers.length
            when 1
              race.race_participations.each do |race_participation|
                stack(:height => 1.0, :width => (0.50)){ 
                  render_racer_name_and_color(race_participation, id)
                }
              end
            when 2
              race.race_participations.each do |race_participation|
                stack(:height => 1.0, :width => (0.4)){ 
                  render_racer_name_and_color(race_participation, id)
                }
              end
              stack(:width => (0.1)){ 
                swap_button(race,"/races/#{id}/edit")
              }
            else
              race.race_participations.each do |race_participation|
                stack(:height => 1.0, :width => (1.0 / $BIKES.length)){ 
                  border eval(race_participation.color), :strokewidth => 50
                  tagline race_participation.racer.name
                  para( "move to:")
                  list_box(:items => race.race_participations.map(&:color) - [race_participation.color]) do |list|
                    new_color = list.text
                    racer = race_participation.racer
                    racers = race.racers
                    old_index = racers.index(racer)
                    new_index = $BIKES.index(new_color)
                    racers[new_index],racers[old_index] = racer,racers[new_index] 
                    race.race_participations.destroy!
                    racers.map {|r|
                      race.race_participations.create(:racer => r)
                    }
                    visit "/races/#{id}/edit"
                  end
                }

              end
          end
        }
        stack {
          flow { @c = c = check; para("Just for fun?"); click { c.toggle; race.update(:for_fun => true) } }
          @c.checked = race.for_fun
          button($i18n.start_race) { visit "/races/#{id}/ready" if race.race_participations.any? }
          if race.tournament_id
            button($i18n.add_another_race) { visit "/races/new/tournament/#{race.tournament_id}"  }
            button($i18n.return_to_event)  { visit "/tournaments/#{race.tournament_id}"           }
          end
        }
      }
    }
  end

  def new_in_tournament(tournament_id)
    race = Race.create(:tournament_id => tournament_id)
    visit "/races/#{race.pk}/edit"
  end
end
