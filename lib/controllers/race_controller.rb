module RaceHelper
  def count_text(text)
    banner text, :font => "140px", :align => 'center'
  end

  def left_names(race)
    @left.clear { 
      stack do # start progress_bars
        race.race_participations.each_with_index do |racer,i|
          stack(:width => 1.0, :height => 81) {
            background(eval(racer.color), :width => 1.0, :height => 70)
            tagline(racer.racer.name, :margin => [10,10,0,0]).displace(0,0)
          }
        end
      end.displace(0,162) # end progress_bars
    }
  end

  def right_bars(race)
    @right.clear { 
      stack do # start progress_bars
        race.race_participations.each_with_index do |racer,i|
          fill right_bar_color||gradient(rgb(230,230,230),rgb(167,167,167), :angle => -90)
          stroke(black(0.0))
          rect(4,81*i+162,@right.width,69)
        end
      end.displace(0,162) # end progress_bars
    }
  end

  def progress_bars(race,speed=false)
    stack do # start progress_bars
      flow {
      race.race_participations.each_with_index do |racer,i|
        if speed
          flow(:width => 0.5){
            flow(:width => 0.5){
              title(racer.speed(racer.finish_time||SENSOR.time), :align => 'right',:margin => [0]*4,
                :stroke => eval(racer.color))
            }
            flow(:width => 0.5){
              title("mph", :margin => [0]*4, :stroke => eval(racer.color))
            }
          }
        else
          flow(:width => 0.5){
            title(" ", :margin => [20]*4)
          }
        end
      end
      }
      race.race_participations.each_with_index do |racer,i|
        fill gradient(rgb(230,230,230),rgb(167,167,167), :angle => -90)
        stroke(black(0.0))
        rect(-1,81*i+162,@center.width+1,69)
        fill eval(racer.color)
        rect(-1,81*i+162,@center.width*racer.percent_complete+1,69)
        #oval(:radius => 34, :left => @center.width*racer.percent_complete+10, :top => 81*i+162)
      end
      
    end.displace(0,0) # end progress_bars
  end

  def stop_save_and_show_winner(race, id)
    @race_animation.stop
    SENSOR.stop
    race.raced = true
    race.save
    race.race_participations.map(&:save)
    visit "/races/#{id}/winner"
  end

  def swap_button(race,rerender_url)
    button($i18n.swap) {
      racers = race.racers.reverse
      race.race_participations.each{|rp|rp.destroy}
      racers.map {|r|
        RaceParticipation.create(:racer => r, :race => race)
      }
      visit rerender_url
    } 
  end

  def render_racer_name_and_color(race_participation,id)
    flow(:height => 0.3) {
      background(eval(race_participation.color), :width=> 0.9)
    }
    flow(:height => 0.3) {
      caption race_participation.racer.name
      delete_button {
        race_participation.destroy
        visit "/races/#{id}/edit"
      }
    }
    flow(:height => 0.3) {
      background(eval(race_participation.color), :width=> 0.9)
    }
  end
end

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
    left_names(race)
    right_bars(race)
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
      progress_bars(race)
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
    left_names(race)
    right_bars(race)
    @nav.clear {
      button("Stop Countdown") { visit "/races/#{id}/ready" }
    }
    @center.clear {
      progress_bars(race)
      f = flow(:width => 1.0){
        flow(:width => 0.3)
        @countbox = flow(:width => 0.4) { }
        flow(:width => 0.3)
      }
      f.displace(0, 22)
    }
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
    left_names(race)
    right_bars(race)
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
          progress_bars(race, true)
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
