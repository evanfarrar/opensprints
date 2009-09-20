if defined? Shoes
  Shoes.setup do
    gem "activesupport"
    gem "bacon"
    gem "dm-core"
    gem "dm-aggregates"
    gem "do_sqlite3"
  end
end
module DefaultStyles
  def custom_font
    nil
  end
  
  def text_color
    nil
  end
  
  def link_color
    nil
  end
  
  def link_hover
    nil
  end
  
  def link_hover_background
    nil
  end

  def container_background
    nil
  end

  def container_border
    nil
  end
  
  def button_background
    nil
  end

  def button_border
    nil
  end

  def divider_color
    nil
  end
end
 
module MainHelper
  def button(text, styles={}, &callback)
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

  def left_button(text, styles={}, &callback)
    button(text, styles.merge({:width => 1.0, :align => 'left', :margin => [10,0,0,0]}), &callback)
  end

  def light_button(text, styles={}, &callback)
    button(text, styles.merge({:stroke => rgb(50,50,50)}), &callback)
  end

  def image_button(path,styles={}, &callback)
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

class Main < Shoes
  url '/', :index

  include DefaultStyles
  include MainHelper

  def custom_styles
    if Shoes::FONTS.grep(/Avenir/).any?
      default_font = "Avenir Black"
    else
      default_font = "Delicious Heavy"
    end
    style(Banner,     :size => 48, :stroke => text_color||black, :font => custom_font||default_font)
    style(Title,      :size => 34, :stroke => text_color||black, :font => custom_font||default_font)
    style(Subtitle,   :size => 26, :stroke => text_color||black, :font => custom_font||default_font)
    style(Tagline,    :size => 18, :stroke => text_color||black, :font => custom_font||default_font)
    style(Caption,    :size => 14, :stroke => text_color||black, :font => custom_font||default_font)
    style(Para,       :size => 12, :margin => [0]*4, :weight => "Bold", :stroke => text_color||black, :font => custom_font||default_font)
    style(Inscription,:size => 10, :stroke => text_color||black, :margin => [0]*4, :font => custom_font||default_font)

    style(Code,       :family => 'monospace')
    style(Del,        :strikethrough => 'single')
    style(Em,         :emphasis => 'italic')
    style(Ins,        :underline => 'single')
    style(Link,       :underline => 'none', :stroke => link_color||"#ffcf01")
    style(LinkHover,  :underline => 'none',  :stroke => link_hover||black, :fill => link_hover_background||"#ffcf01")
    style(Strong,     :weight => 'bold')
    style(Sup,        :rise =>   10,        :size =>  'x-small')
    style(Sub,        :rise =>   -10, :size => 'x-small')
  end
  

  def index
    layout(:main)
    if(defined?(SKIN)&&File.exist?("media/skins/#{SKIN}/logo_with_text.png"))
      logoimage = "media/skins/#{SKIN}/logo_with_text.png"
    else
      logoimage = "media/logo_with_text.png"
    end
    @header.clear
    @nav.clear
    @center.clear {
      stack {
        flow(:attach => Window, :top => (HEIGHT * 0.2).to_i, :left => (WIDTH / 2)-350) { image(logoimage) }
        flow(:attach => Window, :top => (HEIGHT * 0.6).to_i, :left => (WIDTH / 2)-350) {
          caption(link("CATEGORIES", :click => "/categories"))
          caption(" / ", :stroke => link_color)
          caption(link("EVENTS", :click => "/tournaments"))
          caption(" / ", :stroke => link_color)
          caption(link("CONFIGURATION", :click => "/configuration"))
        }
      }
    }
  end

  def nav
    @nav = flow(:attach => Window, :top => 0, :left => 20) {
      button("Return to Main Menu") { visit "/" }
    }
  end
  def layout(background_type=:race)
    custom_styles
    background BACKGROUND_COLOR if(defined?(BACKGROUND_COLOR))
    if(background_type==:menu)
      background MENU_BACKGROUND_IMAGE if(defined?(MENU_BACKGROUND_IMAGE))
      background "media/skins/#{SKIN}/background_menus.png" if(defined?(SKIN)&&File.exist?("media/skins/#{SKIN}/background_menus.png"))
    elsif(background_type==:race)
      background BACKGROUND_IMAGE if(defined?(BACKGROUND_IMAGE))
      background "media/skins/#{SKIN}/background_race.png" if(defined?(SKIN)&&File.exist?("media/skins/#{SKIN}/background_race.png"))
    elsif(background_type==:main)
      background BACKGROUND_IMAGE if(defined?(BACKGROUND_IMAGE))
      background "media/skins/#{SKIN}/background_main.png" if(defined?(SKIN)&&File.exist?("media/skins/#{SKIN}/background_main.png"))
    end
    nav
    @header = flow do
      title @title||TITLE
    end
    @left = stack(:width => 150) do
    end
    @center = flow(:width => width - (175+125), :height => HEIGHT-@header.height-150) do
    end
    @right = flow(:width => 150) do
    end
  end

end
#YAY HAPPY FUN TIME UN-NAMESPACING
Kernel::Main = Main

require 'lib/setup.rb'
if defined? SKIN
  load("media/skins/#{SKIN}/stylesheet.rb") if File.exist?("media/skins/#{SKIN}/stylesheet.rb")
  class Main < Shoes
    include CustomStyles if(defined?(CustomStyles))
  end
end

Shoes.app(:height => HEIGHT, :width => WIDTH, :scroll => false, :title => TITLE)
