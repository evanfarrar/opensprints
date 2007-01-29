class IrosprintsController < ApplicationController
  RED_TRACK_LENGTH = 1315
  BLUE_TRACK_LENGTH = 1200
# 1km = 100,000 centimeters
  def index
    @dial_90_degrees = 8
    @dial_180_degrees = 24
    @dial_270_degrees = 40
    @blue_pointer_angle = speed_to_angle(rand(48))
    @red_pointer_angle = speed_to_angle(rand(48))
    @laps = 3
    @red_dasharray = quadrantificate(765,1315,rand(1315))
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
end
