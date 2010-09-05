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
