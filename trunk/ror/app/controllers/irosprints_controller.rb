class IrosprintsController < ApplicationController
  def poly
    do_math
  end
  def draw_a_polygon
    do_math
    render :partial => 'draw_a_polygon'
  end
private

  def do_math
    sides = random_number_over_two
    str = ""
    @polystring = (1..sides).map do |s| 
      str << "#{(Math::cos(2*Math::PI/sides*s)+1)*70} ,#{(Math::sin(2*Math::PI/sides*s)+1)*70} "
    end
    @polystring = str
  end

  def random_number_over_two
    @sides = Time.now.to_f.to_s.split(//).last.to_i
    @sides > 2 ? @sides : random_number_over_two
  end
end
