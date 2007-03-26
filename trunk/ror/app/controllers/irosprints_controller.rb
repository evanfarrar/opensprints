require 'units/standard'

class IrosprintsController < ApplicationController
  RED_TRACK_LENGTH = 1315
  BLUE_TRACK_LENGTH = 1200
  RED_WHEEL_CIRCUMFERENCE = 2097.mm.to_km
  BLUE_WHEEL_CIRCUMFERENCE = 2097.mm.to_km
  def index
    cleanup
    style
    @dial_90_degrees = 8
    @dial_180_degrees = 24
    @dial_270_degrees = 40
    @red = Racer.new(:wheel_circumference => 2097.mm.to_km,
                     :track_length => 1315, :yaml_name => 'rider-one-tick')
    @blue = Racer.new(:wheel_circumference => 2097.mm.to_km,
                      :track_length => 1315, :yaml_name => 'rider-two-tick')
    read_log
    read_red
    read_blue
    session[:red] = @red
    session[:blue] = @blue
    @laps = 1
  end
  
  def go
    system('ruby lib/sensor.rb &')
    render :text => ''
  end

  def stop
    cleanup
    render :text => ''
  end

  def update
    @red = session[:red]
    @blue = session[:blue]
    read_log
    read_red
    read_blue
    if (@blue.distance>1.0||@red.distance>1.0)
      winner = if (@blue.distance>@red.distance)
        "Red Wins!"
      else
        "Blue Wins!"
      end
      render :update do |page|
        page.replace_html('winner',"<h1>#{winner}</h1>")
      end
    else
      render :update do |page|
        page << "$('blue_pointer').setAttribute('transform','translate(-148.4454,-642.1311) rotate(#{@blue_pointer_angle},315.4454,817.1311)');"
        page << "$('red_pointer').setAttribute('transform','translate(-148.4454,-642.1311) rotate(#{@red_pointer_angle},475.4454,817.1311)');"
        page << "$('blue_track').setAttribute('style','fill:none;stroke:#abbcf4;stroke-width:17.33102798;stroke-dasharray:#{@blue_dasharray};');"
        page << "$('red_track').setAttribute('style','fill:none;stroke:#d3040a;stroke-width:19.05940628;stroke-dasharray:#{@red_dasharray};');"
      end
    end
  end

  def reset
    redirect_to :index
  end

private
# this method is specific to the track interface...extract?
  def quadrantificate(offset=700, total=1200, distance=0)
    if distance > offset
      [0,0,offset,((total-offset)-(distance-offset))]
    else
      [0,(offset-distance),distance,(total-offset)]
    end
  end

  def speed_to_angle(speed)
    unadjusted = ((speed/48.0)*270.0+45.0)
    unadjusted-180
  end

  def read_log
    @log = File.read('log/sensor.log'){|f| f.readlines}
  end

  def read_blue
    @blue.set(@log)
    track = BLUE_TRACK_LENGTH*@blue.distance
    @blue_dasharray = quadrantificate(700, BLUE_TRACK_LENGTH, track).join(',')
    @blue_pointer_angle = speed_to_angle(@blue.speed)
  end

  def read_red
    @red.set(@log)
    track = RED_TRACK_LENGTH*@red.distance
    @red_dasharray = quadrantificate(765, RED_TRACK_LENGTH, track).join(',')
    @red_pointer_angle = speed_to_angle(@red.speed)
  end

  def style
    File.open('public/stylesheets/svg.css') do |f|
      @stylishness = f.readlines.join
    end
  end

  def cleanup
    system("ls tmp/pids/|grep sensor|cut -d. -f2 | xargs kill -9")
    system("echo ''>log/sensor.log")
  end
end
