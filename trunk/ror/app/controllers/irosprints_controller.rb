class IrosprintsController < ApplicationController
  def index
    @pointer_angle = rand(180+90)-180 
  end
end
