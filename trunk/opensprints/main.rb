puts ((['rubygems','rubygame','units/standard','yaml'].map do |gem_name|
  begin
    require gem_name
    nil
  rescue LoadError
    "#{gem_name} is not installed"
  end
end).compact)

require 'lib/dashboard_controller'
require 'lib/racer'

options = YAML::load(File.read('conf.yml'))
require "lib/sensors/#{options['sensor']['file']}_sensor"
SENSOR_LOCATION = options['sensor']['device']
RACE_DISTANCE = options['race_distance'].meters.to_km
RED_TRACK_LENGTH = 1315
BLUE_TRACK_LENGTH = 1200
RED_WHEEL_CIRCUMFERENCE = options['wheel_circumference']['red'].mm.to_km
BLUE_WHEEL_CIRCUMFERENCE = options['wheel_circumference']['blue'].mm.to_km
TITLE = options['title']


class OpenSprintsGame
  def self.run
    @clock = Rubygame::Clock.new{|c| c.target_framerate = 60}
    Rubygame.init
    Rubygame::TTF.setup
    screen = Rubygame::Screen.set_mode([794,614], 16, [Rubygame::HWSURFACE,Rubygame::ANYFORMAT])
    @dashboard_controller = DashboardController.new 
    @dashboard_controller.start
    queue = Rubygame::EventQueue.new
    loop do
      screen.update
      queue.each do |event|
        case(event)
        when Rubygame::QuitEvent
          return
        when Rubygame::KeyDownEvent
          exit if event.string == "q"
        end
      end
      screen.fill([61,52,53])
      @dashboard_controller.update.blit(screen,[0,0])
#      Rubygame::Clock.wait 15
      puts @clock.tick()      
    end
  end
end

if __FILE__ == $0
  OpenSprintsGame.run
end

