# for some reason, when a scrollable slot has native controls, 
# the native controls render even when they should be scrolled out of view.

class ConfigController < Shoes::Main
  url '/configuration', :index
  url '/configuration/data_file', :data_file
  url '/configuration/appearance', :appearance
  url '/configuration/locale', :locale
  url '/configuration/skin', :skin
  url '/configuration/hardware', :hardware
  url '/configuration/bikes', :bikes
  url '/configuration/upgrade', :upgrade

  def config_setup
    layout(:menu)
    @left.clear {
      left_button("Appearance") { visit '/configuration/appearance' }
      left_button("Skin") { visit '/configuration/skin' }
      left_button("Hardware") { visit '/configuration/hardware' }
      left_button("Bikes") { visit '/configuration/bikes' }
      left_button("Locale") { visit '/configuration/locale' }
      left_button("Data") { visit '/configuration/data_file' }
      if(PLATFORM =~ /linux/)
        left_button("Upgrade") { visit '/configuration/upgrade' }
      end
    }
    if File.exists?(File.join(LIB_DIR,'opensprints_conf.yml'))
      @prefs = YAML::load_file(File.join(LIB_DIR,'opensprints_conf.yml'))
    else
      @prefs = YAML::load_file('conf-sample.yml')
    end
  end

  def appearance
    config_setup
    if RUBY_PLATFORM =~ /linux/
      width,height = `xrandr | grep '*'`.split[0].split('x')
      height = options['window_height'].to_i.nonzero?||(height.to_i-100)
    else
      width,height = 1024,768
    end
    @header.clear { title "Appearance" }

    @center.clear do
      flow(:height => @center.height-50, :width => 1.0) do
        container
        flow(:height => @center.height-150, :scroll => true) do
          stack(:width => 0.4) do
            stack(:margin => 10) do
              inscription 'title (e.g. RockySprints):'
              edit_line(@prefs['title']) do |edit|
                @prefs['title'] = edit.text
              end
            end

            stack(:margin => 10, :padding => 0) do
              inscription "usable window height (e.g. #{[(height.to_i - 100),550].max}):"
              edit_line(@prefs['usable_window_height']) do |edit|
                @prefs['usable_window_height'] = edit.text
              end
              inscription(link("(what's this?)",:click => "http://wiki.opensprints.org/index.php?title=Usable_Screen_Height"))
            end

          end
          stack(:width => 0.6) do
            stack(:margin => 10) do

              inscription "window height (e.g. #{height.to_i - 100}):"
              edit_line(@prefs['window_height']) do |edit|
                @prefs['window_height'] = edit.text
              end
              inscription "window width (e.g. #{width.to_i - 50}):"
              edit_line(@prefs['window_width']) do |edit|
                @prefs['window_width'] = edit.text
              end
            end
          end
        end
        stack do
          save_button
        end
      end
    end
  end
  def skin
    config_setup
    @header.clear { title "Skin" }

    @center.clear do
      flow(:height => @center.height-50, :width => 1.0) do
        container
        flow(:height => @center.height-150, :scroll => true) do
          stack(:width => 0.4) do
            stack do
              inscription 'Background color:'
              color_edit = edit_line(@prefs['background_color']) do |edit|
                @prefs['background_color'] = edit.text
              end
              button "pick color" do
                color_edit.text = ask_color('pick...')
                @prefs['background_color'] = color_edit.text
              end
              inscription 'Background image:'
              image_edit = edit_line(@prefs['background_image']) do |edit|
                @prefs['background_image'] = edit.text
              end
              button "pick file" do
                image_edit.text = ask_open_file
                @prefs['background_image'] = image_edit.text
              end
              inscription 'Menu Background image:'
              m_image_edit = edit_line(@prefs['menu_background_image']) do |edit|
                @prefs['menu_background_image'] = edit.text
              end
              button "pick file" do
                m_image_edit.text = ask_open_file
                @prefs['menu_background_image'] = m_image_edit.text
              end
            end
          end
          stack(:width => 0.6) do
            stack(:margin => 10) do
              inscription 'Skin:'
              sensors = Dir.glob('media/skins/*').map do |s|
                s.gsub(/media\/skins\/(.*)/, '\1')
              end
              list_box(:items => [nil]+sensors,
                :choose => @prefs['skin']) do |changed|
                  @prefs['skin'] = changed.text
              end
            end
          end
        end
        stack do
          save_button
        end
      end
    end
  end

  def data_file
    config_setup
    @header.clear { title "Data" }
    @center.clear do
      container
      stack do
        button("Delete all data", :width => 200) do
          DataMapper.auto_migrate! if confirm("Are you sure? There's no going back.")
        end

        button("Export to MySQL", :width => 200) do
          location = ask_save_file
          if location != nil
              File.copy(File.join(LIB_DIR,'opensprints_data.db'),"/tmp/tmp-opensprints.db")
              system("sqlite3 /tmp/tmp-opensprints.db .dump .quit | sed s/\\\"/\\\`/g | grep -v \"BEGIN TRANSACTION\" | grep -v \"COMMIT\" | sed s/AUTOINCREMENT/AUTO_INCREMENT/g > /tmp/tmp-opensprints.sql")
              File.copy("/tmp/tmp-opensprints.sql",location)
          end
          location = nil
        end

        button("Export SQLite", :width => 200) do
            location = ask_save_file
            if location != nil
                File.copy(File.join(LIB_DIR,'opensprints_data.db'),location)
            end
            location = nil
        end
      end
    end
  end
  
  def index
    config_setup
    @header.clear { title "Configuration" }
  end

  def bikes
    config_setup
    @header.clear { title "Bike Setup" }
    @center.clear do
      stack(:height => @center.height-50, :width => 0.8) do
        container
        stack(:height => @center.height-150, :scroll => true) do
          stack(:margin => 10) do
            inscription 'Bikes:'
            @prefs['bikes']||=[]
            @r = 4.times do |i|
              flow do
                inscription "Bike #{i+1} Color:"
                color_edit = edit_line(@prefs['bikes'][i]) do |edit|
                  @prefs['bikes'][i] = edit.text
                end
                button "pick color" do
                  color_edit.text = ask_color('pick...')
                  @prefs['bikes'][i] = color_edit.text
                end
                box = check { |change|
                  if change.checked?
                    color_edit.state = nil
                  else
                    color_edit.state = "disabled"
                    @prefs['bikes'][i] = nil
                  end
                }
                if @prefs['bikes'][i] && color_edit.text != ""
                  box.checked = true
                  color_edit.state = nil
                else
                  color_edit.state = "disabled"
                end
                inscription "active?"
              end
            end
          end
        end
        stack do
          save_button
        end

      end
    end
  end

  def hardware
    config_setup
    @header.clear { title "Hardware & Rollers" }
    
    @center.clear do
      stack(:height => @center.height-50, :width => 0.8) do
        container
        flow(:height => @center.height-150, :scroll => true) do
          stack(:width => 0.5) do
            stack(:margin => 10) do
              inscription 'Race distance (METERS):'
              edit_line(@prefs['race_distance']) do |edit|
                @prefs['race_distance'] = edit.text.to_f
              end
            end

            stack(:margin => 10) do
              inscription 'Roller circumference (METERS):'
              edit_line(@prefs['roller_circumference']) do |edit|
                @prefs['roller_circumference'] = edit.text.to_f
              end
              inscription "e.g. 4.5 in. roller drum = 0.35908404 meters"
              inscription "e.g. 3.0 in. roller drum = 0.23938936 meters"
            end
          end

          stack(:width => 0.5) do
            stack(:margin => 10) do
              inscription 'Sensor type:'
              sensors = Dir.glob('lib/sensors/*_sensor.rb').map do |s|
                s.gsub(/lib\/sensors\/(.*)_sensor\.rb/, '\1')
              end
              list_box(:items => sensors,
                :choose => @prefs['sensor']['type']) do |changed|
                  @prefs['sensor']['type'] = changed.text
                  if (changed.text=="mock")||(changed.text=="network")
                    @sensor_location_edit.state = "disabled"
                  else
                    @sensor_location_edit.state = nil
                  end
              end
            end

            stack(:margin => 10) do
              inscription 'Sensor location:'
              @sensor_location_edit = edit_line(@prefs['sensor']['device']) do |edit|
                @prefs['sensor']['device'] = edit.text
              end
              inscription "e.g. Linux: /dev/ttyUSB0"
            end
          end
        end
        stack do
          save_button
        end

      end
    end
  end

  def save_button
    button "Save!" do
      @prefs['bikes'].compact!
      old_width = WIDTH
      old_height = HEIGHT
      old_skin = SKIN
      File.open(File.join(LIB_DIR,'opensprints_conf.yml'), 'w+') do |f|
        f << @prefs.to_yaml
      end
      load "lib/setup.rb"
      alert('Preferences saved!')
      if(old_width!=WIDTH||old_height!=HEIGHT)
        if((PLATFORM =~ /linux/)&&!(`which opensprints`).empty?)
          alert("window dimensions have changed, restarting...")
          fork ? exit : exec("opensprints")
        else
          alert("window dimensions have changed, please restart opensprints for this to take effect.")
          exit
        end
      end
      if(old_skin!=SKIN)
        if((PLATFORM =~ /linux/)&&!(`which opensprints`).empty?)
          alert("Skin has changed, restarting...")
          fork ? exit : exec("opensprints")
        else
          alert("Skin has changed, please restart opensprints for this to take effect.")
          exit
        end
      end
      
      visit '/configuration'
    end
  end

  def upgrade
    config_setup
    @header.clear { title "Upgrade" }
    @center.clear do
      container
      stack do
        version = `dpkg-query -W -f='${Version}' opensprints`
        version = File.readlines('build/debian/changelog').first.gsub(/.*\((.*)\).*/,'\1').strip if version.empty?
        para "You're using version: #{version}"
        button("Update!", :width => 200) do
          `update-manager`
        end
      end
    end
  end

  def locale
    config_setup
    @header.clear { title "Appearance" }

    @center.clear do
      flow(:height => @center.height-50, :width => 1.0) do
        container
        flow(:height => @center.height-150, :scroll => true) do
          stack(:width => 0.6) do
            stack(:margin => 10, :padding => 0) do
              stack(:margin => 0) do
                inscription "Display speed in:", :margin => 0
                metric = nil; standard = nil;
                flow(:margin => 0) do
                  standard = radio(:units){ @prefs['units'] = 'standard'}
                  inscription 'standard', :margin => 2
                end
                flow(:margin => 0) do
                  metric = radio(:units){ @prefs['units'] = 'metric'}
                  inscription 'metric', :margin => 2
                end
                if @prefs['units'] == 'metric'
                  metric.checked = true
                else
                  standard.checked = true
                end
              end
            end
          end
          stack(:width => 0.6) do
            stack(:margin => 10) do
              inscription 'Locale:'
              sensors = Dir.glob('lib/translations/*').map do |s|
                s.gsub(/lib\/translations\/(.*).yml/, '\1')
              end
              list_box(:items => [nil]+sensors,
                :choose => @prefs['locale']) do |changed|
                  @prefs['locale'] = changed.text
              end
            end
          end
        end
        stack do
          save_button
        end
      end
    end
  end
end
