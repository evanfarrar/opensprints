module RacerHelper
  def create_categorizations_for_checkboxes(racer)
    racer.categorizations.each{|cz|cz.destroy}
    @checkboxes.each do |cb, category|
      Categorization.create(:category => category, :racer => racer) if cb.checked?
    end
  end
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
          para(link(r.name,:click => "/racers/#{r.pk}"))
        }
      end
    }
  end

  def edit(id, tournament_id)
    racer = Racer[id]
    tournament = Tournament[tournament_id]
    #TODO: DRY
    tournament_participation = TournamentParticipation.filter(:tournament_id => tournament_id, :racer_id => id).first||TournamentParticipation.create(:racer => racer, :tournament => tournament)
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
              @checkboxes = Category.all.map do |category|
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
            elsif old_racer = Racer.filter(:name => racer.name).exclude(:id => racer.pk).any?
              TournamentParticipation.create(:racer => old_racer, :tournament => tournament)
              old_racer.save
              old_racer.categorizations.each{|cz|cz.destroy}
              create_categorizations_for_checkboxes(old_racer)
              racer.destroy
              visit session[:referrer].pop||'/racers'
            else
              racer.save
              tournament_participation.save
              create_categorizations_for_checkboxes(racer)
              if Racer[racer.pk].name.blank? && racer.name.blank?
                TournamentParticipation.filter(:racer_id => racer.pk).all
                racer.destroy
              end
              visit session[:referrer].pop||'/racers'
            end
          end
          button $i18n.cancel do
            racer.destroy if Racer[racer.pk].try(:name).blank?
            #TODO: optimize
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
    #TODO: DRY
    tournament_participation = TournamentParticipation.filter(:tournament_id => tournament.pk, :racer_id => id).first||TournamentParticipation.create(:racer => racer, :tournament => tournament)
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
              @checkboxes = Category.all.map do |category|
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
            elsif old_racer = Racer.filter(:name => racer.name).exclude(:id => racer.pk).any?
              TournamentParticipation.create(:racer => old_racer, :tournament => tournament)
              old_racer.save
              create_categorizations_for_checkboxes(old_racer)
              RaceParticipation.create(:racer => old_racer, :race => race)
              racer.destroy
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
          button $i18n.cancel do
            racer.destroy if Racer[racer.pk].try(:name).blank?
            TournamentParticipation.all.each{ |tp| tp.destroy if tp.racer.nil? }
            visit "/races/#{race_id}/edit"
          end
        }
      }
    }
    timer(0.01) { @e.focus }
  end
end
