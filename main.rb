


Shoes.app do
  stack do
    button "configuration" do
      load 'lib/config_app.rb'
    end

    button "race with names" do
      alert('not implemented!')
    end

    button "race a tournament" do
      alert('not implemented!')
    end

    button "Just Race!" do
      load 'lib/race_app.rb'
    end
  end
end
