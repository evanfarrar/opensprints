require 'thread'
class DashboardController
  def rgb(r,g,b)
    Gdk::Color.new((r*65535)/255,(g*65535)/255,(b*65535)/255)
  end
  
  def make_layout(cr, text)
    layout = cr.create_pango_layout
    layout.text = text
    layout.font_description = Pango::FontDescription.new("DIN 1451 Std 18")
    cr.update_pango_layout(layout)
    layout
  end

  def initialize(context)
    @red = Racer.new(:wheel_circumference => RED_WHEEL_CIRCUMFERENCE,
                     :track_length => 1315, :yaml_name => '1')
    @blue = Racer.new(:wheel_circumference => BLUE_WHEEL_CIRCUMFERENCE,
                    :track_length => 1315, :yaml_name => '2')
    @continue = false
    sp = Cairo::SurfacePattern.new(Cairo::ImageSurface.from_png('views/mockup.png'))
    context.set_source(sp)
    context.paint
    
    context.set_source_color rgb(252,252,252)
    context.rectangle(30, 97, 157, 1)
    context.rectangle(210, 97, 530, 1)
    context.stroke
##sstart/end labels
##   context.set_source_rgb(203,195,192)
    context.set_source_color rgb(203,195,192)
#    context.rectangle(27, 129, 19, 189)
#    context.rectangle(727, 129, 19, 189)
##pprogress borders
    context.rectangle(27, 129, 718, 1)
    context.rectangle(27, 318, 718, 1)
    context.fill

    context.set_source_color rgb(61,52,52)

    context.move_to(44, 362)
    context.line_to(44, 0)
    path = context.copy_path_flat
    start_text = make_layout(context, 'START')
    context.pango_layout_line_path(start_text.get_line(0))
    context.map_path_onto(path)
    context.fill

    context.set_source_color rgb(0,252,252)
    context.move_to(625, 362)
    context.line_to(625, 0)
    path = context.copy_path_flat
    start_text = make_layout(context, 'FINISH')    
    context.pango_layout_line_path(start_text.get_line(0))
    context.map_path_onto(path)

    context.fill

##sstatboxes
    context.set_source_color rgb(165,86,64)
    context.rectangle(27, 357, 226, 99)
    context.fill
    context.set_source_color rgb(77,134,161)
    context.rectangle(269, 357, 226, 99)
    context.fill
##nnameboxes
    context.set_source_color rgb(207,95,55)
    context.rectangle(27, 332, 226, 25)
    context.fill
    context.set_source_color rgb(65,167,207)
    context.rectangle(269, 332, 226, 25)
    context.fill
    context.set_source_color rgb(203,195,192)
    context.rectangle(27, 471, 718, 98)
    context.stroke
    @last_blue_tick = [45,318]
    @last_red_tick = [45,318]
    @context = context

    @width = context.line_width
    @cap = context.line_cap
  end
  
  def build_template
    xml_data = ''
    xml = Builder::XmlMarkup.new(:target => xml_data)
    svg = ''
    File.open('views/svg.rb') do |f|
      svg = f.readlines.join
    end
    eval svg
    xml_data.gsub!(/%([^s])/,'%%\1')
  end

  def start
    @continue = true
    @queue = Queue.new
    @sensor = Sensor.new(@queue)
    @sensor.start
  end
  def stop
    @sensor.stop
  end

  def refresh
    partial_log = []
    @queue.length.times do
      partial_log << @queue.pop
    end
    if partial_log.any?
      if (blue_log = partial_log.grep(/^2/))
        @blue.update(blue_log)
      end
      if (red_log = partial_log.grep(/^1/))
        @red.update(red_log)
      end
      if @blue.distance>RACE_DISTANCE or @red.distance>RACE_DISTANCE
        winner = (@red.distance>@blue.distance) ? 'RED' : 'BLUE'
        @sensor.stop
        @continue = false
      else
        blue_progress = 683*@blue.percent_complete
        @context.set_source_color rgb(54,127,155) 
        @context.rectangle(45, 150, blue_progress, 20)
        @context.fill
#        @surface.draw_box_s([269, 357], [495, 456], [77,134,161])
        
        red_progress = 683*@red.percent_complete
        @context.set_source_color rgb(159,77,56)
        @context.rectangle(45, 129, red_progress, 20)
        @context.fill
#        @surface.draw_box_s([27, 357], [253, 456], [165,86,64])
        @context.set_source_color rgb(203,195,192) 
        @context.rectangle(27, 129, 718, 1)
        @context.rectangle(27, 150, 718, 1)
        @context.rectangle(27, 171, 718, 1)
        @context.fill

        @context.line_width = 3
        @context.line_cap = Cairo::LineCap::ROUND
        tick_at = graph_tick(@red.distance, @red.speed)
        @context.set_source_color rgb(159,77,56)
        @context.move_to(*@last_red_tick)
        @context.curve_to(*(@last_red_tick+tick_at+tick_at))
        @context.stroke
        @last_red_tick = tick_at
        

        tick_at = graph_tick(@blue.distance, @blue.speed)
        @context.set_source_color rgb(54,127,155)
        @context.move_to(*@last_blue_tick)
        @context.curve_to(*(@last_blue_tick+tick_at+tick_at))
        @context.stroke
        @last_blue_tick = tick_at

        @context.line_width = @width
        @context.line_cap = @cap
        @continue = true
      end
    end
  end
  def continue?
    @continue
  end


  def graph_tick(distance, speed)
    [(distance/RACE_DISTANCE.to_f*(726-45) + 45),
     (147 - ([speed,50.0].min/50.0 * 147) + 171)]
  end


end
