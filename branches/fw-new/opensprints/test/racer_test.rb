require 'rubygems'
require 'test/unit'
require 'units/standard'
require 'models/racer'
class RacerTest < Test::Unit::TestCase

  def test_create
    r1 = Racer.new(:yaml_name => 'blah')
    assert_equal 0,r1.distance
    assert_equal 2097.mm.to_km,r1.wheel_circumference
    
    r2 = Racer.new(:wheel_circumference => 2145.mm.to_km, :yaml_name => 'blah')
    
    assert_equal 2145.mm.to_km,r2.wheel_circumference
  end
  
  def test_progressing_distance
    r = Racer.new(:wheel_circumference => 1.km,
                   :yaml_name => 'rider-one-tick')
    
    yaml = [15.1234]*50
    r.update(yaml)
    assert_equal 50.km, r.distance

    r.update([16.1234])
    assert_equal 51.km, r.distance
  end

  def test_speed_is_moving_average
    r = Racer.new(:wheel_circumference => 1.km,
                   :yaml_name => 'rider-one-tick')
    
    c = 0
    ticks = ([15.1234]*50).map{|d| d+(c+=1)}
    r.update(ticks[0...40])
    assert_equal 40.km, r.distance
    assert_equal 3600, r.speed # 60km/m
    
    c = 0
    ticks = ticks.map{|d| d+1}
    r.update([ticks[40]])
    assert_equal 41.km, r.distance
    assert_equal 3000, r.speed # 60km/m
  end
end
