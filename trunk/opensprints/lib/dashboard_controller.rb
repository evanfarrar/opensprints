require 'thread'
class DashboardController
 
  def DashboardController.rgb(r,g,b)
    Gdk::Color.new((r*65535)/255,(g*65535)/255,(b*65535)/255)
  end 
  @@gray = rgb(61, 52, 53)
  def rgb(r,g,b)
    self.class.rgb(r,g,b)
  end
  
  def make_layout(cr, text, size, bold = nil)
    layout = cr.create_pango_layout
    layout.text = text
    layout.font_description = 
      Pango::FontDescription.new("DIN 1451 Std #{bold} #{size.to_s}")
    cr.update_pango_layout(layout)
    layout
  end

  def initialize(context)
    @red = Racer.new(:wheel_circumference => RED_WHEEL_CIRCUMFERENCE,
                     :track_length => 1315, :yaml_name => '1',
                     :name => 'Racer 1')
    @blue = Racer.new(:wheel_circumference => BLUE_WHEEL_CIRCUMFERENCE,
                      :track_length => 1315, :yaml_name => '2',
                      :name => 'Racer 2')
    @continue = false
    @last_time = '0:00:00'
#   sp = Cairo::SurfacePattern.new(Cairo::ImageSurface.from_png('views/mockup.png'))
#   context.set_source(sp)
       
    context.set_source_color @@gray
    context.paint
    context.set_source_color rgb(252,252,252)
    context.rectangle(30, 97, 157, 1)
    context.rectangle(210, 97, 530, 1)
    context.fill
#start/end labels
    context.set_source_color rgb(203,195,192)
    context.rectangle(27, 129, 19, 189)
    context.rectangle(727, 129, 19, 189)
#progress borders
    context.rectangle(27, 129, 718, 1)
    context.rectangle(27, 318, 718, 1)
    context.fill

#statboxes
    context.set_source_color rgb(165,86,64)
    context.rectangle(27, 357, 226, 99)
    context.fill
    context.set_source_color rgb(77,134,161)
    context.rectangle(269, 357, 226, 99)
    context.fill
#nameboxes
    context.set_source_color rgb(207,95,55)
    context.rectangle(27, 332, 226, 25)
    context.fill
    context.set_source_color rgb(65,167,207)
    context.rectangle(269, 332, 226, 25)
    context.fill
    context.set_source_color rgb(203,195,192)
    context.rectangle(27, 471, 718, 98)
    context.stroke
# START
    context.set_source_color @@gray
    context.move_to(44, 316)
    context.line_to(44, 0)
    path = context.copy_path_flat
    context.new_path
    start_text = make_layout(context, 'START', 16, 'bold')
    context.pango_layout_line_path(start_text.get_line(0))
    context.map_path_onto(path)
    context.fill

# FINISH
    context.new_path
    context.set_source_color @@gray
    context.move_to(745, 316)
    context.line_to(745, 0)
    path = context.copy_path_flat
    context.new_path
    finish_text = make_layout(context, 'FINISH', 16, 'bold')    
    context.pango_layout_line_path(finish_text.get_line(0))
    context.map_path_onto(path)
    context.fill

# IRO
    context.new_path
    context.set_source_color rgb(255,255,0)
    context.move_to(70, 90)
    context.line_to(500,90)
    path = context.copy_path_flat
    context.new_path
    iro_text = make_layout(context, 'IRO', 42)    
    context.pango_layout_line_path(iro_text.get_line(0))
    context.map_path_onto(path)
    context.fill

# Sprints
    context.new_path
    context.set_source_color rgb(255,255,255)
    context.move_to(160, 90)
    context.line_to(600,90)
    path = context.copy_path_flat
    context.new_path
    iro_text = make_layout(context, 'Sprints', 42)    
    context.pango_layout_line_path(iro_text.get_line(0))
    context.map_path_onto(path)
    context.fill

# Racer1
    context.new_path
    context.set_source_color @@gray
    context.move_to(30, 352)
    context.line_to(600,352)
    path = context.copy_path_flat
    context.new_path
    iro_text = make_layout(context, @red.name, 16)    
    context.pango_layout_line_path(iro_text.get_line(0))
    context.map_path_onto(path)
    context.fill
    context.stroke

# Racer2
    context.new_path
    context.set_source_color @@gray
    context.move_to(272, 352)
    context.line_to(600,352)
    path = context.copy_path_flat
    context.new_path
    iro_text = make_layout(context, @blue.name, 16)    
    context.pango_layout_line_path(iro_text.get_line(0))
    context.map_path_onto(path)
    context.fill

    @last_blue_tick = [45,318]
    @last_red_tick = [45,318]
    @context = context

    @width = context.line_width
    @cap = context.line_cap
  end
  
  def start
    @continue = true
    @queue = Queue.new
    @sensor = Sensor.new(@queue, SENSOR_LOCATION)
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
    if (partial_log=partial_log.grep(/^[12]/)).any?
      
      @last_time = timeize(SecsyTime.parse(partial_log[-1].split(";")[1]))
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
        blue_progress = 685*@blue.percent_complete
        @context.set_source_color rgb(54,127,155) 
        @context.rectangle(47, 150, blue_progress, 20)
        @context.fill
#        @surface.draw_box_s([269, 357], [495, 456], [77,134,161])
        
        red_progress = 685*@red.percent_complete
        @context.set_source_color rgb(159,77,56)
        @context.rectangle(47, 129, red_progress, 20)
        @context.fill
#        @surface.draw_box_s([27, 357], [253, 456], [165,86,64])
        @context.set_source_color rgb(203,195,192) 
        @context.rectangle(27, 129, 718, 1)
        @context.rectangle(27, 149, 718, 1)
        @context.rectangle(27, 170, 718, 1)
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
#Draw red speed
        @context.set_source_color rgb(165,86,64)
        @context.rectangle(27, 357, 226, 99)
        @context.fill
        @context.new_path
        @context.set_source_color @@gray
        @context.move_to(30, 450)
        @context.line_to(600,450)
        path = @context.copy_path_flat
        @context.new_path
        iro_text = make_layout(@context, [@red.speed.round.to_i,99].min.to_s, 76, false)    
        @context.pango_layout_line_path(iro_text.get_line(0))
        @context.map_path_onto(path)
        @context.fill
#Draw blue speed
        @context.set_source_color rgb(77,134,161)
        @context.rectangle(269, 357, 226, 99)
        @context.fill
        @context.new_path
        @context.set_source_color @@gray
        @context.move_to(272, 450)
        @context.line_to(600,450)
        path = @context.copy_path_flat
        @context.new_path
        iro_text = make_layout(@context, [@blue.speed.round.to_i,99].min.to_s, 76, false)    
        @context.pango_layout_line_path(iro_text.get_line(0))
        @context.map_path_onto(path)
        @context.fill
        @context.line_width = @width
        @context.line_cap = @cap
        @continue = true
      end
    end
    @context.rectangle(610, 325, 140, 40)
    @context.set_source_color @@gray
    @context.fill
    @context.new_path
    @context.set_source_color rgb(255,255,255)
    @context.move_to(610, 350)
    @context.line_to(740,350)
    path = @context.copy_path_flat
    @context.new_path
    iro_text = make_layout(@context, @last_time, 24, true)    
    @context.pango_layout_line_path(iro_text.get_line(0))
    @context.map_path_onto(path)
    @context.fill
  end
  def continue?
    @continue
  end


  def graph_tick(distance, speed)
    [(distance/RACE_DISTANCE.to_f*(726-45) + 47),
     (147 - ([speed,50.0].min/50.0 * 147) + 171)]
  end

  def timeize(t)
    "%1i:%02i.%02i" % [(t.mins),(t.secs),(t.hunds)]
  end
end
