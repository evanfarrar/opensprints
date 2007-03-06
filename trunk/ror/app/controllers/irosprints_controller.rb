class IrosprintsController < ApplicationController
  RED_TRACK_LENGTH = 1315
  BLUE_TRACK_LENGTH = 1200
# 1km = 100,000 centimeters
  def index
    @dial_90_degrees = 8
    @dial_180_degrees = 24
    @dial_270_degrees = 40
    read_log
    read_red
    @blue_pointer_angle = speed_to_angle(rand(48))
    @laps = 3
    @blue_dasharray = quadrantificate(700,1200,rand(1200))
    @blue_dasharray = @blue_dasharray.join(',')
    @red_dasharray = @red_dasharray.join(',')
  end

private
  def quadrantificate(offset=700, total=1200, distance=0)
# over 700 
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

  def read_red
    a = @log.select{|l|l=~/one-tick/}
    distance = (a.length*0.7)
    @red_dasharray =quadrantificate(765, RED_TRACK_LENGTH, distance)
    last = YAML::load(a[-2])['rider-one-tick']
    this = YAML::load(a[-1])['rider-one-tick']
    @red_pointer_angle = speed_to_angle(rotation_elapsed_to_kmh(this-last))
  end

  def rotation_elapsed_to_kmh(elapsed)
    ((700.0/(elapsed))/(1000.0*100.0))*3600.0
  end
end
