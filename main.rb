require 'yaml'

begin
  options = YAML::load(File.read('conf.yml'))
rescue
  alert "You must write a conf.yml. See sample in conf-sample.yml"
end
require 'lib/units/base'
require 'lib/units/standard'
SENSOR_LOCATION = options['sensor']['device']
RACE_DISTANCE = options['race_distance'].meters.to_km
$ROLLER_CIRCUMFERENCE = options['roller_circumference'].mm.to_km
TITLE = options['title']
require 'lib/racer'
require 'lib/race'
require 'lib/interface_widgets'
require 'lib/tournament'
require 'lib/secsy_time'
require "lib/sensors/#{options['sensor']['type']}_sensor"

if options['units'] == 'standard'
  UNIT_SYSTEM = :mph
else    
  UNIT_SYSTEM = :kmph
end

class RacePresenter
  attr_accessor :winner
  def initialize(shoes_instance, distance, update_area, race)
    @shoes_instance = shoes_instance
    @bar_size = 800-2*60
    @race_distance = distance
    @race = race
    @red = @race.red_racer
    @blue = @race.blue_racer
    @update_area = update_area
  end

  def continue?; @continue end

  def refresh
    unless @started
      @queue = Queue.new
      @sensor = Sensor.new(@queue, SENSOR_LOCATION)
      @sensor.start
      @started=true
      @continue = true
    end
    partial_log = []
    @queue.length.times do
      q = @queue.pop
      if q =~ /;/
        partial_log << q
      end
    end
    if (partial_log=partial_log.grep(/^[12]/)).any?
      if (blue_log = partial_log.grep(/^2/))
        @blue.update(blue_log)
      end
      if (red_log = partial_log.grep(/^1/))
        @red.update(red_log)
      end
      @update_area.clear do
        @shoes_instance.stroke gray 0.5
        @shoes_instance.strokewidth 4
        @shoes_instance.line 60-4,280,60-4,380
        @shoes_instance.line 800-60+4,280,800-60+4,380
        blue_progress = @bar_size*percent_complete(@blue)
        @shoes_instance.stroke "#00F"
        @shoes_instance.fill "#FEE".."#32F", :angle => 90, :radius => 10
        @shoes_instance.rect 60, 300, blue_progress, 20 
        
        red_progress = @bar_size*percent_complete(@red)
        @shoes_instance.stroke "#F00"
        @shoes_instance.fill "#FEE".."#F23", :angle => 90, :radius => 10
        @shoes_instance.rect 60, 340, red_progress, 20 
        if @blue.distance>RACE_DISTANCE and @red.distance>RACE_DISTANCE
          if (@red.tick_at(@race_distance)<@blue.tick_at(@race_distance)) 
            self.winner = @red
            @red.wins += 1
            @blue.losses += 1
          else
            self.winner = @blue
            @red.losses += 1
            @blue.wins += 1
          end
          @red.record_time(@red.tick_at(@race_distance))
          @blue.record_time(@blue.tick_at(@race_distance))
          @shoes_instance.title "#{self.winner.name.upcase} WINS!!!\n", :align => "center",
            :top => 380, :width => 800 
          @shoes_instance.title "#{@red.name}: #{@red.tick_at(@race_distance)}, #{@blue.name}: #{@blue.tick_at(@race_distance)}",
            :align => 'center', :top => 450, :width => 800
          @sensor.stop
          @continue = false
          @race.red_racer = @red
          @race.blue_racer = @blue
          @shoes_instance.owner.tournament_record(@race)
          @shoes_instance.owner.post_race
        end
      end    
    end
  end

  def stop
    @sensor.stop
  end

  def percent_complete(racer)
    [1.0, racer.distance/@race_distance.to_f].min
  end
end


Shoes.app :title => TITLE, :width => 800, :height => 600 do
  extend InterfaceWidgets
  @tournament = Tournament.new

  def list_racers
    @tournament.racers.each do |racer|
      flow do 
        border black
        equis racer
        para racer.name
        para racer.wins
        para racer.losses
        para racer.best_time
      end
    end
  end

  def post_race
    @racer_list.clear do
      list_racers
    end

    @matches.clear do
      list_matches
    end
  end

  def tournament_record(race)
    @tournament.record(race)
  end

  def list_matches
    border black
    title "Matches"
    @tournament.matches.each do |match|
      flow(:margin => 5) do 
        background lightgrey
        border black
        para "#{match[0].name} vs #{match[1].name}"
        button("race")do
          window :title => TITLE, :width => 800, :height => 600 do
            background white

            stack do
              image "media/track.jpg", :top => -450
              banner TITLE, :top => 150, :align => "center", :background => magenta
              @update_area = stack {}
              race = lambda do
                @start.hide
                r = RacePresenter.new(self, RACE_DISTANCE, @update_area,
                             match[2])
                
                @countdown = 5
                @start_time = Time.now+5
                count_box = stack{ @label = banner "#{@countdown}..." }
                @race_animation = animate(14) do
                  @now = Time.now
                  if @now < @start_time
                    count_box.clear do
                      banner "#{(@start_time-@now).round}..."
                    end
                  else
                    count_box.remove
                    r.refresh
                    @start.show unless r.continue?
                  end
                end
              end
              @start = button("Start Race") do
                race.call
              end

              button("Quit") do
                @race_animation.stop
                close
              end
            end
          end
        end
      end
    end      
  end


  background white
  stack(:width => 380, :margin => 5) do
    border black
    title "Racers"
    @racer_list = stack { list_racers }
    flow do
      @racer_name = edit_line "enter name"
      plus
    end
  end

  @matches = stack(:width => 290, :margin => 5) do
    list_matches
  end

  button "autofill matches" do
    @tournament.autofill_matches
    @matches.clear do
      list_matches
    end
  end

  def add_racer(name)
    duped = @tournament.racers.any? do |racer|
      racer.name == name
    end
    if !duped && name!='enter name'
      @tournament.racers << Racer.new(:name => name, :units => UNIT_SYSTEM)
      @racer_list.clear { list_racers }
    end
  end

end
