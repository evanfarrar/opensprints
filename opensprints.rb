if defined? Shoes
  Shoes.setup do
    gem "activesupport"
    gem "bacon"
    gem "dm-core"
    gem "dm-aggregates"
    gem "do_sqlite3"
  end
end
 
module MainHelper
  def button(text, styles={}, &callback)
    stack(:height => 32, :width => styles[:width]||(40+(text.length * 8)), :margin => [5,10,5,0], :padding_top => 0) do
      background(styles[:fill]||("#e5e6e6"..."#c1c2c4"), :curve => 1)
      border(black) if styles[:border]
      t = inscription(text, :align => styles[:align]||'center', :stroke => styles[:stroke]||black, :margin => styles[:margin]||[0]*4)
      click &callback
      hover {
        t.underline = 'single'
      }
      leave {
        t.underline = 'none'
      }
    end
  end

  def left_button(text, styles={}, &callback)
    button(text, styles.merge({:width => 1.0, :align => 'left', :margin => [10,0,0,0]}), &callback)
  end

  def light_button(text, styles={}, &callback)
    button(text, styles.merge({:stroke => rgb(50,50,50)}), &callback)
  end

  def container
    background("#e5e6e6"..."#babcbe", :curve => 1)
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
      n.times { inscription '-', :margin => 4, :stroke => gray(0.8) }
    end
  end
end

class Main < Shoes
  url '/', :index

  include MainHelper

  def custom_styles
    if Shoes::FONTS.grep(/Avenir/).any?
      default_font = "Avenir Black"
    else
      default_font = "Delicious Heavy"
    end
    style(Banner,     :size => 48, :stroke => black, :font => default_font)
    style(Title,      :size => 34, :stroke => black, :font => default_font)
    style(Subtitle,   :size => 26, :stroke => black, :font => default_font)
    style(Tagline,    :size => 18, :stroke => black, :font => default_font)
    style(Caption,    :size => 14, :stroke => black, :font => default_font)
    style(Para,       :size => 12, :margin => [0]*4, :weight => "Bold", :stroke => black, :font => default_font)
    style(Inscription,:size => 10, :stroke => black, :margin => [0]*4, :font => default_font)

    style(Code,       :family => 'monospace')
    style(Del,        :strikethrough => 'single')
    style(Em,         :emphasis => 'italic')
    style(Ins,        :underline => 'single')
    style(Link,       :underline => 'none', :stroke => "#ffcf01")
    style(LinkHover,  :underline => 'none',  :stroke => black, :fill => "#ffcf01")
    style(Strong,     :weight => 'bold')
    style(Sup,        :rise =>   10,        :size =>  'x-small')
    style(Sub,        :rise =>   -10, :size => 'x-small')
  end
  

  def index
    layout
    @header.clear
    @nav.clear
    @center.clear {
      stack {
        flow(:attach => Window, :top => (HEIGHT * 0.2).to_i, :left => (WIDTH / 2)-350) { image("media/logo_with_text.png") }
        flow(:attach => Window, :top => (HEIGHT * 0.6).to_i, :left => (WIDTH / 2)-350) {
          caption(link("categories", :click => "/categories"))
          caption(" / ", :stroke => "#ffcf01")
          caption(link("events", :click => "/tournaments"))
          caption(" / ", :stroke => "#ffcf01")
          caption(link("configuration", :click => "/configuration"))
        }
      }
    }
  end

  def nav
    @nav = flow(:attach => Window, :top => 0, :left => 20) {
      button("Return to Main Menu") { visit "/" }
    }
  end

  def layout(background_type=:normal)
    custom_styles
    background BACKGROUND_COLOR if(defined?(BACKGROUND_COLOR))
    if(background_type==:menu)
      background MENU_BACKGROUND_IMAGE if(defined?(MENU_BACKGROUND_IMAGE))
    else
      background BACKGROUND_IMAGE if(defined?(BACKGROUND_IMAGE))
    end
    nav
    @header = flow do
      banner TITLE
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

Shoes.app(:height => HEIGHT, :width => WIDTH, :scroll => false, :title => TITLE)
