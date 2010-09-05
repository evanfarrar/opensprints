module RacerHelper
  def create_categorizations_for_checkboxes(racer)
    racer.categorizations.each{|cz|cz.destroy}
    @checkboxes.each do |cb, category|
      Categorization.create(:category => category, :racer => racer) if cb.checked?
    end
  end

  def find_or_create_participation(racer, tournament) 
    TournamentParticipation.filter(:tournament_id => tournament.pk, :racer_id => racer.pk).first||TournamentParticipation.create(:racer => racer, :tournament => tournament)
  end


  def create_old_racer(old_racer, racer, tournament)
    TournamentParticipation.create(:racer => old_racer, :tournament => tournament)
    old_racer.save
    create_categorizations_for_checkboxes(old_racer)
    racer.destroy
  end
  
  def cancel_button(racer,after_url)
    button $i18n.cancel do
      racer.destroy if Racer[racer.pk].try(:name).blank?
      # Delete all participations where the racer_id is not in racers.
      TournamentParticipation.exclude(:id => TournamentParticipation.join(:racers, :id => :racer_id).select(:tournament_participations__id)).delete
      visit after_url
    end
  end
  
  def render_racer_form(racer, tournament_participation)
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
  end
end
