require 'units/standard'
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
    read_blue
    @laps = 3
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
    a = @log.select{|l|l=~/two-tick/}
    distance = BLUE_TRACK_LENGTH*((a.length)*(700.cm.to_km))
    @blue_dasharray = quadrantificate(765, BLUE_TRACK_LENGTH, distance)
    @blue_dasharray = @blue_dasharray.join(',')
    last = YAML::load(a[-2])['rider-two-tick']
    this = YAML::load(a[-1])['rider-two-tick']
    spd = rotation_elapsed_to_kmh(this-last)
    @blue_pointer_angle = speed_to_angle(spd)
  end

  def read_red
    a = @log.select{|l|l=~/one-tick/}
    distance = RED_TRACK_LENGTH*((a.length)*(700.cm.to_km))
    @red_dasharray = quadrantificate(765, RED_TRACK_LENGTH, distance)
    @red_dasharray = @red_dasharray.join(',')
    last = YAML::load(a[-2])['rider-one-tick']
    this = YAML::load(a[-1])['rider-one-tick']
    spd = rotation_elapsed_to_kmh(this-last)
    @red_pointer_angle = speed_to_angle(spd)
  end

  def rotation_elapsed_to_kmh(elapsed)
    ((700.cm.to_km/(elapsed))/(1.km))*1.hour.to_seconds
  end
end
