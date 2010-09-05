module MainHelper
  def button(text, styles={}, &callback)
    if admin_window?
      stack(:height => 32, :width => styles[:width]||(40+(text.length * 8)), :margin => [5,10,5,0], :padding_top => 0) do
        background(button_background||styles[:fill]||("#e5e6e6"..."#c1c2c4"), :curve => 1)
        border(button_border||styles[:border]||"#ffcf01")
        t = inscription(text, :align => styles[:align]||'center', :stroke => styles[:stroke]||black, :margin => styles[:margin]||[0]*4)
        click &callback
        hover {
          self.cursor = :hand
        }
        leave {
          self.cursor = :arrow
        }
      end
    end
  end

  def left_button(text, styles={}, &callback)
    button(text, styles.merge({:width => 1.0, :align => 'left', :margin => [10,0,0,0]}), &callback)
  end

  def light_button(text, styles={}, &callback)
    button(text, styles.merge({}), &callback)
  end

  def image_button(path,styles={}, &callback)
    if admin_window?
      stack(:margin_top => 8, :width => 20) do
        click &callback
        b = background(link_hover_background||"#ffcf01")
        image path
        b.hide
        hover {
          b.show
          self.cursor = :hand
        }
        leave {
          b.hide
          self.cursor = :arrow
        }
      end
    end
  end

  def delete_button(styles={}, &callback)
    image_button("media/cross.png", styles, &callback)
  end
  def edit_button(styles={}, &callback)
    image_button("media/application_form_edit.png", styles, &callback)
  end

  def container
    background(container_background||("#e5e6e6"..."#babcbe"), :curve => 1)
    border(container_border||"#ffcf01")
  end

  def session
    if(defined?(@@session) && @@session)
      @@session
    else
      @@session = {:referrer => []}
    end
  end

  def separator_line(n=45)
    flow(:height => 18, :scroll => false) do
      inscription '_'*n, :margin => [0]*4, :stroke => divider_color||"#ffcf01"
    end
  end

  def small_logo
    if(defined?(SKIN)&&File.exist?("media/skins/#{SKIN}/logo_text.png"))
      image("media/skins/#{SKIN}/logo_text.png", :attach => Window, :top => 30, :left => WIDTH-110)
    else
      image("media/logo_text.png", :attach => Window, :top => 30, :left => WIDTH-110)
    end
  end
end
