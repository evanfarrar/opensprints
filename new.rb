class Main < Shoes
  url '/', :index

  def custom_styles
    style(Banner,     :size => 48)
    style(Title,      :size => 34)
    style(Subtitle,   :size => 26)
    style(Tagline,    :size => 18)
    style(Caption,    :size => 14)
    style(Para,       :size => 12, :margin => [0]*4)
    style(Inscription,:size => 10)

    style(Code,       :family => 'monospace')
    style(Del,        :strikethrough => 'single')
    style(Em,         :emphasis => 'italic')
    style(Ins,        :underline => 'single')
    style(Link,       :underline => 'none', :stroke => '#02f')
    style(LinkHover,  :underline => 'single',  :stroke => '#02f')
    style(Strong,     :weight => 'bold')
    style(Sup,        :rise =>   10,        :size =>  'x-small')
    style(Sub,        :rise =>   -10, :size => 'x-small')
  end
  

  def index
    layout
    @nav.clear {
      para(link "racers", :click => "/racers")
      para(link "categories", :click => "/categories")
      para(link "tournaments", :click => "/tournaments")
      para(link "configuration", :click => "/configuration")
    }
  end

  def nav
    @nav = flow(:attach => Window, :top => 0, :left => 20) {
      para(link "index", :click => "/")
    }
  end

  def layout
    custom_styles
    nav
    @header = flow do
      banner "OpenSprints"
    end
    @left = stack(:width => 150) do
    end
    @center = flow(:width => width - (175+125)) do
    end
    @right = flow(:width => 150) do
    end
  end

end
#YAY HAPPY FUN TIME UN-NAMESPACING
Kernel::Main = Main

require 'lib/setup.rb'
load 'test/fixtures.rb'

Shoes.app(:height => HEIGHT, :width => WIDTH, :scroll => false)
