require 'thread'

class DashboardController
  def initialize
    @red = Racer.new(:wheel_circumference => RED_WHEEL_CIRCUMFERENCE,
                     :track_length => 1315, :yaml_name => '1')
    @blue = Racer.new(:wheel_circumference => BLUE_WHEEL_CIRCUMFERENCE,
                    :track_length => 1315, :yaml_name => '2')
    @laps = 1
    @continue = true
    @surface = Rubygame::Surface.new([794,614])
    @surface.fill([61,52,53])
#    @surface = Rubygame::Surface.load_image('views/mockup.jpg')
    @chris_awesome_font = Rubygame::TTF.new('views/DINMittelschriftStd.otf', 60)
    @chris_awesome_font2 = Rubygame::TTF.new('views/DINEngschriftStd.otf', 115)
    @chris_awesome_font.render('IRO', true, [254,240,2]).blit(@surface,[70,47]) 
    @chris_awesome_font.render('Sprints', true, [255,255,255]).blit(@surface,[157,47])
# "gradient"
    h = 2
    (1..50).each do |n|
      @surface.draw_box_s([0, 613-((n*h)-h)], [794, 614-(n*h)], [252,252,252, (255-(255*(n/50.0)))*0.5])
    end

#title underline
    @surface.draw_box_s([30, 97], [187, 97], [252,252,252])
    @surface.draw_box_s([210, 97], [740, 97], [252,252,252])
#start/end labels
    @surface.draw_box_s([27, 129], [44, 318], [203,195,192])
    @surface.draw_box_s([727, 129], [745, 318], [203,195,192])
#progress borders
    @surface.draw_box_s([27, 129], [745, 129], [203,195,192])
    @surface.draw_box_s([27, 318], [745, 318], [203,195,192])
#statboxes
    @surface.draw_box_s([27, 357], [253, 456], [165,86,64])
    @surface.draw_box_s([269, 357], [495, 456], [77,134,161])
#nameboxes
    @surface.draw_box_s([27, 332], [253, 357], [207,95,55])
    @surface.draw_box_s([269, 332], [495, 357], [65,167,207])
#message box
    @surface.draw_box([27, 471], [745, 559], [203,195,192])

    @last_blue_tick = [45,318]
    @last_red_tick = [45,318]
  end
  
  def read
  end
 
  def start
    @queue = Queue.new
    @sensor = Sensor.new(@queue)
    @sensor.start
  end

  def stop
    @sensor.stop
  end

  def update
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
        @chris_awesome_font.render("#{winner} WINS!", true, [255,255,255]).blit(@surface, [0,0])
      end
      blue_progress = 683*@blue.percent_complete
      @surface.draw_box_s([45, 150], [45+blue_progress, 170],  [54,127,155])
      @surface.draw_box_s([269, 357], [495, 456], [77,134,161])
      @chris_awesome_font2.render("%.0f" % @blue.speed, true,[65,167,207]).blit(@surface, [279,365])
      
      red_progress = 683*@red.percent_complete
      @surface.draw_box_s([45, 129], [45+red_progress, 149],[159,77,56])
      @surface.draw_box_s([27, 357], [253, 456], [165,86,64])
      @chris_awesome_font2.render("%.0f" % @red.speed, true, [207,95,55]).blit(@surface, [37,365])
    
      @surface.draw_box_s([27, 129], [745, 129], [203,195,192])
      @surface.draw_box_s([27, 150], [745, 150], [203,195,192])
      @surface.draw_box_s([27, 171], [745, 171], [203,195,192])

      tick_at = graph_tick(@red.distance, @red.speed)
      @surface.draw_polygon_s([ @last_red_tick.map{|e|e+3}, @last_red_tick, tick_at, tick_at.map{|e|e+2}], [159,77,56])
      @last_red_tick = tick_at


      tick_at = graph_tick(@blue.distance, @blue.speed)
      @surface.draw_polygon_s([ @last_blue_tick.map{|e|e+3}, @last_blue_tick, tick_at, tick_at.map{|e|e+2}], [54,127,155])
      @last_blue_tick = tick_at
    end
    @surface
  end

  def graph_tick(distance, speed)
    [(distance/RACE_DISTANCE.to_f*(726-45) + 45),
     (147 - ([speed,50.0].min/50.0 * 147) + 171)]
  end


end
