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
    @chris_awesome_font.render('IRO', true, [254,240,2]).blit(@surface,[70,47]) 
    @chris_awesome_font.render('Sprints', true, [255,255,255]).blit(@surface,[157,47])
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
    @surface.draw_box_s([27, 332], [253, 456], [165,86,64])
    @surface.draw_box_s([269, 332], [495, 456], [77,134,161])
#nameboxes
    @surface.draw_box_s([27, 332], [253, 357], [207,95,55])
    @surface.draw_box_s([269, 332], [495, 357], [65,167,207])
#message box
    @surface.draw_box([27, 471], [745, 559], [203,195,192])

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
      @surface.draw_box_s([45, 129], [44+blue_progress, 149], [54,127,155])
      red_progress = 683*@red.percent_complete
      @surface.draw_box_s([45, 150], [44+red_progress, 170], [159,77,56])
    end
    @surface
  end

end
