class RacerController < Shoes::Main
  include RacerHelper
  url '/racers', :list
  url '/racers/(\d+)/(\d+)', :edit
  url '/racers/(\d+)/race/(\d+)', :edit_in_race
  url '/racers/new', :new
  url '/racers/new/tournament/(\d+)', :new_in_tournament
  url '/racers/new/race/(\d+)', :new_in_race

  def list
    layout    
    @center.clear {
      stack do
        button("new racer") { visit "/racers/new" }
        Racer.all.each {|r|
          para(link(r.name,:click => "/racers/#{r.pk}"))
        }
      end
    }
  end

  def edit(id, tournament_id)
    racer = Racer[id]
    tournament = Tournament[tournament_id]
    tournament_participation = find_or_create_participation(racer,tournament)
    return_to_url = session[:referrer].pop
    layout
    @center.clear {
      container
      stack{
        flow {
          stack(:width => 0.4) { render_racer_form(racer, tournament_participation) }
          stack(:width => 0.05)
          stack(:width => 0.4) {
            if best = tournament_participation.best_time
              #TODO i18n
              para "Best time in this event:","#{"%.2f" % best} seconds"
            end
            if best = racer.best_time
              #TODO i18n
              para "Best time ever:","#{"%.2f" % best} seconds"
            end
          }
        }
        
        flow {
          button $i18n.save do
            if((tournament.racers-[racer]).any? { |r| racer.name == r.name })
              alert("Racer is already in this event.")
            elsif racer.name.blank?
              alert "Sorry, name is required."
            elsif old_racer = Racer.filter(:name => racer.name).exclude(:id => racer.pk).first
              create_old_racer(old_racer, racer, tournament)
              visit(return_to_url||'/racers')
            else
              racer.save
              tournament_participation.save
              create_categorizations_for_checkboxes(racer)
              if Racer[racer.pk].name.blank? && racer.name.blank?
                racer.destroy
              end
              visit(return_to_url||'/racers')
            end
          end
          cancel_button(racer,return_to_url||'/racers')
        }
      }
    }
    timer(0.01) { @e.focus }
  end

  def new
    racer = Racer.create
    visit "/racers/#{racer.pk}"
  end

  def new_in_tournament(tournament_id)
    racer = Racer.create
    visit "/racers/#{racer.pk}/#{tournament_id}"
  end

  def new_in_race(race_id)
    racer = Racer.create
    visit "/racers/#{racer.pk}/race/#{race_id}"
  end

  def edit_in_race(id, race_id)
    racer = Racer[id]
    race = Race[race_id]
    tournament = race.tournament
    tournament_participation = find_or_create_participation(racer, tournament)
    layout
    @center.clear {
      container
      stack{
        flow {
          stack(:width => 0.4) { render_racer_form(racer, tournament_participation) }
          stack(:width => 0.05)
          stack(:width => 0.4) {
            if best = tournament_participation.best_time
              #TODO i18n
              para "Best time in this event:","#{"%.2f" % best} seconds"
            end
            if best = racer.best_time
              #TODO i18n
              para "Best time ever:","#{"%.2f" % best} seconds"
            end
          }
        }
        flow {
          button $i18n.save do
            if((tournament.racers-[racer]).any? { |r| racer.name == r.name })
              alert("Racer is already in this event.")
            elsif racer.name.blank?
              alert "Sorry, name is required."
            elsif old_racer = Racer.filter(:name => racer.name).exclude(:id => racer.pk).first
              create_old_racer(old_racer, racer, tournament)
              visit "/races/#{race_id}/edit"
            else
              racer.save
              tournament_participation.save
              create_categorizations_for_checkboxes(racer)
              if Racer[racer.pk].name.blank? && racer.name.blank?
                racer.destroy
              else
                rp = RaceParticipation.create(:racer => racer, :race => race)
              end
              visit "/races/#{race_id}/edit"
            end
          end
          cancel_button(racer,"/races/#{race_id}/edit")
        }
      }
    }
    timer(0.01) { @e.focus }
  end
end
