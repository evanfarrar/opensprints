$LOAD_PATH.insert(-1,'./lib/sequel/lib')

Shoes.setup do
  gem "activesupport"
  gem "r18n-desktop"
#  gem "sequel 3.5.0"
  source "http://gemcutter.org"
  gem "opensprints-core 0.6.1"
  gem "multipart-post"
end

require 'lib/shoes_extensions'
Dir.glob('lib/helpers/*.rb').each do |helper|
  require helper
end

class Main < Shoes
  url '/', :index

  include DefaultStyles
  extend AudienceAdminSeperation::ClassMethods
  include AudienceAdminSeperation::InstanceMethods
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
        flow(:attach => Window, :top => (@center.height * 0.2).to_i, :left => (WIDTH / 2)-350) { image(logoimage) }
        if admin_window?
          flow(:attach => Window, :top => (@center.height * 0.6).to_i, :left => (WIDTH / 2)-350) {
            caption(link($i18n.categories, :click => "/categories"))
            caption(" / ", :stroke => link_color)
            caption(link($i18n.events, :click => "/tournaments"))
            caption(" / ", :stroke => link_color)
            caption(link($i18n.configuration, :click => "/configuration"))
          }
          flow(:attach => Window, :top => (@center.height * 0.65).to_i, :left => (WIDTH / 2)-250) {
            caption(link("AUDIENCE WINDOW", :click => lambda{
              if !$child && !owner # if we are the parent, and we haven't yet created the child
                $child = window(:height => HEIGHT, :width => WIDTH, :scroll => false, :title => TITLE)
              end
            } ))
          }
        end
      }
    }
  end

  def nav
    @nav = flow(:attach => Window, :top => 0, :left => 20) {
      button($i18n.return_to_main_menu) { visit "/" }
    }
  end
  def layout(background_type=:race)
    if audience_window?
      animate(20) do
        if owner.location != app.location && audience_friendly_url?(owner.location)
          visit owner.location
        end
      end
    end
    self.cursor = :arrow
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
    @center = flow(:width => width - (175+125), :height => ((USABLE_HEIGHT||HEIGHT)-@header.height-125)) do
    end
    @right = flow(:width => 150) do
    end
  end

end
#YAY HAPPY FUN TIME UN-NAMESPACING
Kernel::Main = Main

require 'lib/setup.rb'

Shoes.app(:height => HEIGHT, :width => WIDTH, :scroll => false, :title => TITLE)
