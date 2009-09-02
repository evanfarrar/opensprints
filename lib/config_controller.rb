class ConfigController < Shoes::Main
  url '/configuration', :index
  url '/configuration/data_file', :data_file

  def data_file
    layout
    @nav.append {
      button("Back") { visit '/configuration' }
    }
    @center.clear do
      container
      button "Delete all data" do
        DataMapper.auto_migrate! if confirm("Are you sure? There's no going back.")
      end

      button "Export to mysql." do
        
      end

      button "Export SQLite" do
        ask_save_file("opensprints.db") do |location|
          File.copy(File.join(LIB_DIR,'opensprints.db'),location)
        end
      end

      button "Upload my settings to server" do

      end
 
      button "Get my settings from server" do

      end
      
    end
  end

  def index
    layout

    @nav.append {
      button("Data Management") { visit '/configuration/data_file' }
    }
    @center.clear do
      if File.exists?(File.join(LIB_DIR,'opensprints_conf.yml'))
        @prefs = YAML::load_file(File.join(LIB_DIR,'opensprints_conf.yml'))
      else
        @prefs = YAML::load_file('conf-sample.yml')
      end
      stack(:height => @center.height-50, :width => 0.8) do
        container
        stack(:height => @center.height-150, :scroll => true) do
          stack(:margin => 20) do
            para 'title (e.g. RockySprints):'
            edit_line(@prefs['title']) do |edit|
              @prefs['title'] = edit.text
            end
          end

          stack(:margin => 20) do
            para 'Race distance (METERS):'
            edit_line(@prefs['race_distance']) do |edit|
              @prefs['race_distance'] = edit.text.to_f
            end
          end

          stack(:margin => 20) do
            para 'Roller circumference (METERS):'
            edit_line(@prefs['roller_circumference']) do |edit|
              @prefs['roller_circumference'] = edit.text.to_f
            end
          end

          stack(:margin => 20, :padding => 0) do
            stack(:margin => 0) do
              para "Display speed in:", :margin => 0
              metric = nil; standard = nil;
              flow(:margin => 0) do
                standard = radio(:units){ @prefs['units'] = 'standard'}
                para 'standard', :margin => 2
              end
              flow(:margin => 0) do
                metric = radio(:units){ @prefs['units'] = 'metric'}
                para 'metric', :margin => 2
              end
              if @prefs['units'] == 'metric'
                metric.checked = true
              else
                standard.checked = true
              end
            end
          end

          stack(:margin => 20) do
            para 'Track Skin:'
            sensors = Dir.glob('lib/race_windows/*.rb').map do |s|
              s.gsub(/lib\/race_windows\/(.*)\.rb/, '\1')
            end
            list_box(:items => sensors,
              :choose => @prefs['track']) do |changed|
                @prefs['track'] = changed.text

            end
          end
          stack(:margin => 20) do
            para 'Background (color or image):'
            flow do
              color_edit = edit_line(@prefs['background']) do |edit|
                @prefs['background'] = edit.text
              end
              button "pick color" do
                color_edit.text = ask_color('pick...')
                @prefs['background'] = color_edit.text
              end
              button "pick file" do
                color_edit.text = ask_open_file
                @prefs['background'] = color_edit.text
                @prefs['bikes'][i] = color_edit.text
              end
            end
          end
          stack(:margin => 20) do
            para 'Sensor type:'
            sensors = Dir.glob('lib/sensors/*_sensor.rb').map do |s|
              s.gsub(/lib\/sensors\/(.*)_sensor\.rb/, '\1')
            end
            list_box(:items => sensors,
              :choose => @prefs['sensor']['type']) do |changed|
                @prefs['sensor']['type'] = changed.text

            end
          end
          stack(:margin => 20) do
            para 'Sensor location:'
            edit_line(@prefs['sensor']['device']) do |edit|
              @prefs['sensor']['device'] = edit.text
            end
            para "e.g. Mac OS X: /dev/tty.usbmodem0000103D1"
            para "e.g. Linux: /dev/ttyUSB0"
            para "e.g. Windows: com6"
          end


          stack(:margin => 20) do
            para 'Bikes:'
            @prefs['bikes']||=[]
            @r = 4.times do |i|
              flow do
                para "Bike #{i+1} Color:"
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
                para "active?"
              end
            end
          end

          stack(:margin => 20) do
            para 'window height:'
            edit_line(@prefs['window_height']) do |edit|
              @prefs['window_height'] = edit.text
            end
            para 'window width:'
            edit_line(@prefs['window_width']) do |edit|
              @prefs['window_width'] = edit.text
            end
          end


        end
        stack do
          button "Save!" do
            @prefs['bikes'].compact!
            old_width = WIDTH
            old_height = HEIGHT
            File.open(File.join(LIB_DIR,'opensprints_conf.yml'), 'w+') do |f|
              f << @prefs.to_yaml
            end
            load "lib/setup.rb"
            if(old_width!=WIDTH||old_height!=HEIGHT)
              alert("window dimensions have changed, please restart opensprints for this to take effect.")
            end
            alert('Preferences saved!')
            visit '/'
          end
        end

      end
    end
  end

end
