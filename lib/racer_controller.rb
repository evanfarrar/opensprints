module RacerHelper
end

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
          para $i18n.name
          @e = edit_line(racer.name) do |edit|
            racer.name = edit.text
          end
        }
        separator_line
        flow {
          para $i18n.assign_to_categories
          stack {
            stack(:width => 0.5) {
              @checkboxes = ObsCategory.all.map do |category|
                flow { @c = c = check; para(category.name); click { c.toggle } }
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
          para $i18n.eliminated
        }
        
        flow {
          button $i18n.save do
            if((tournament.racers-[racer]).any? { |r| racer.name == r.name })
              alert("Racer is already in this event.")
            elsif racer.name.blank?
              alert "Sorry, name is required."
            elsif old_racer = Racer.first(:name => racer.name, :id.not => racer.id)
              TournamentParticipation.create(:racer => old_racer, :tournament => tournament)
              old_racer.save
              old_racer.categorizations.destroy!
              @checkboxes.each do |cb, category|
                old_racer.categorizations.create(:category => category) if cb.checked?
              end
              TournamentParticipation.all(:racer => racer)
              racer.destroy
              visit session[:referrer].pop||'/racers'
            else
              racer.save
              tournament_participation.save
              racer.categorizations.destroy!
              @checkboxes.each do |cb, category|
                racer.categorizations.create(:category => category) if cb.checked?
              end
              if Racer.get(racer.id).name.blank? && racer.name.blank?
                TournamentParticipation.all(:racer => racer)
                racer.destroy
              end
              visit session[:referrer].pop||'/racers'
            end
          end
          button $i18n.cancel do
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

  def new_in_race(race_id)
    racer = Racer.create
    visit "/racers/#{racer.id}/race/#{race_id}"
  end

  def edit_in_race(id, race_id)
    racer = Racer.get(id)
    race = Race.get(race_id)
    tournament = race.tournament
    tournament_participation = TournamentParticipation.first(:tournament => tournament, :racer => racer)||TournamentParticipation.create(:racer => racer, :tournament => tournament)
    layout
    @center.clear {
      container
      stack{
        flow {
          para $i18n.name
          @e = edit_line(racer.name) do |edit|
            racer.name = edit.text
          end
        }
        separator_line
        flow {
          para $i18n.assign_to_categories
          stack {
            stack(:width => 0.5) {
              @checkboxes = ObsCategory.all.map do |category|
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
          para $i18n.eliminated
        }
        
        flow {
          button $i18n.save do
            if((tournament.racers-[racer]).any? { |r| racer.name == r.name })
              alert("Racer is already in this event.")
            elsif racer.name.blank?
              alert "Sorry, name is required."
            elsif old_racer = Racer.first(:name => racer.name, :id.not => racer.id)
              TournamentParticipation.create(:racer => old_racer, :tournament => tournament)
              old_racer.save
              old_racer.categorizations.destroy!
              @checkboxes.each do |cb, category|
                old_racer.categorizations.create(:category => category) if cb.checked?
              end
              RaceParticipation.create(:racer => old_racer, :race => race)
              TournamentParticipation.all(:racer => racer)
              racer.destroy
              visit "/races/#{race_id}/edit"
            else
              racer.save
              tournament_participation.save
              racer.categorizations.destroy!
              @checkboxes.each do |cb, category|
                racer.categorizations.create(:category => category) if cb.checked?
              end
              if Racer.get(racer.id).name.blank? && racer.name.blank?
                TournamentParticipation.all(:racer => racer)
                racer.destroy
              else
                rp = RaceParticipation.create(:racer => racer, :race => race)
              end
              visit "/races/#{race_id}/edit"
            end
          end
          button $i18n.cancel do
            racer.destroy if Racer.get(racer.id).try(:name).blank?
            TournamentParticipation.all.each{ |tp| tp.destroy if tp.racer.nil? }
            visit "/races/#{race_id}/edit"
          end
        }
      }
    }
    timer(0.01) { @e.focus }
  end
end
