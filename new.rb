module MainHelper
  def button(text, styles={}, &callback)
    stack(:height => 32, :width => styles[:width]||(40+(text.length * 8)), :margin_right => 10, :margin_top => 10) do
      background(gray(0.2,0.5), :curve => 5)
      t = inscription text
      click &callback
      hover {
        t.underline = 'single'
      }
      leave {
        t.underline = 'none'
      }
    end

  end
end

class Main < Shoes
  url '/', :index

  include MainHelper

  def custom_styles
    style(Banner,     :size => 48, :stroke => white)
    style(Title,      :size => 34)
    style(Subtitle,   :size => 26)
    style(Tagline,    :size => 18)
    style(Caption,    :size => 14)
    style(Para,       :size => 12, :margin => [0]*4, :weight => "Bold", :stroke => white)
    style(Inscription,:size => 10, :stroke => white)

    style(Code,       :family => 'monospace')
    style(Del,        :strikethrough => 'single')
    style(Em,         :emphasis => 'italic')
    style(Ins,        :underline => 'single')
    style(Link,       :underline => 'none', :stroke => white)
    style(LinkHover,  :underline => 'single',  :stroke => white)
    style(Strong,     :weight => 'bold')
    style(Sup,        :rise =>   10,        :size =>  'x-small')
    style(Sub,        :rise =>   -10, :size => 'x-small')
  end
  

  def index
    layout
    @nav.clear {
      button("racers") { visit "/racers"}
      button("categories") { visit "/categories"}
      button("tournaments") { visit "/tournaments"}
      button("configuration") { visit "/configuration"}
    }
  end

  def nav
    @nav = flow(:attach => Window, :top => 0, :left => 20) {
      button("index") { visit "/" }
    }
  end

  def layout
    custom_styles
    background black
    background BACKGROUND
    background black(0.25)
    nav
    @header = flow do
      banner TITLE
    end
    @left = stack(:width => 150) do
    end
    @center = flow(:width => width - (175+125), :height => HEIGHT-@header.height-100) do
    end
    @right = flow(:width => 150) do
    end
  end

end
#YAY HAPPY FUN TIME UN-NAMESPACING
Kernel::Main = Main

require 'lib/setup.rb'

Shoes.app(:height => HEIGHT, :width => WIDTH, :scroll => false)
