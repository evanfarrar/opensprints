module CustomStyles
  def custom_font
    "Avenir Black"
  end
  
  def text_color
    "#636466"
  end
  
  def link_color
    "#636466"
  end
  
  def link_hover
    black
  end
  
  def link_hover_background
    "#c1e0d3"
  end

  def container_background
    "#c1e0d3"
  end

  def container_border
    "#636466"
  end
  
  def button_background
    "#c1e0d3"
  end

  def button_border
    "#636466"
  end

  def divider_color
    "#636466"
  end

  def small_logo
    image("media/skins/#{SKIN}/logo_text.png", :attach => Window, :top => 30, :left => WIDTH-200)
  end
end
