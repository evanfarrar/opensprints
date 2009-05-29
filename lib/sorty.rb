module Sorty

  def sort_names(race, colors, &after)
    old_self = self
    window(:width => 200, :height => 70 * 4 + 40) do
      @next_color = colors.cycle
      @next_color.next

      @previous_color = colors.cycle
      (colors.length - 1).times { @previous_color.next }


      def swappy(array,item)
        idx = array.index(item)
        array[(yield(idx)) % array.length],array[idx] = array[idx],array[(idx-1) % array.length]
        array
      end
      def swap_previous(array, item)
        swappy{|idx| idx-1}
      end
      def swap_next(array, item)
        swappy{|idx| idx+1}
      end
      def names_n_colors(people, colors, race, &after)
        clear do
          background black
          names_n_colors = colors.zip(people).map do |color, person|
            flow(:height => 70, :width => 200) do
              border color, :strokewidth => 4
              my_label = subtitle person, :stroke => white
              fill @previous_color.next
              rotate(90)
              a = arrow(104, 5, 30)
              a.click { names_n_colors(swap_previous(people, person), colors, race, &after)  }
              fill @next_color.next
              rotate(180)
              a = arrow(90, 45, 30)
              a.click { names_n_colors(swap_next(people, person), colors, race, &after)  }
            end
          end

          button("ok!") { race.racers = people; after.call; close }
        end
      end

      names_n_colors(race.racers, colors, race, &after)
    end
  end
end

