class IrosprintsController < ApplicationController
  RED_TRACK_LENGTH = 1315
  BLUE_TRACK_LENGTH = 1200
# 1km = 100,000 centimeters
  def index
    @pointer_angle = rand(180+90)-180
    @laps = 3
    @red_dasharray = [1315,10e12]
    @blue_dasharray = [1200,10e12]
    [@red_dasharray,@blue_dasharray].map!{|da|da.join(',')}
  end
end
