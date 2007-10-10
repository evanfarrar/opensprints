xml.svg(:height => "597", :width => "800", :viewBox => "0 0 499 378",
        :xmlns => "http://www.w3.org/2000/svg",
        :'xmlns:xlink'=>"http://www.w3.org/1999/xlink",
        :version => "1.0",
        :baseProfile=>"full") {
  xml.defs{
    xml.style(:type=>'text/css'){ xml.cdata!(@stylishness) }
  }
  xml.rect(
     :rx=>"110.20203",
     :style=>"fill:none;stroke:white;stroke-width:36.48699951;",
     :ry=>"118.27761",
     :y=>"34.320671",
     :x=>"38.267757",
     :height=>"305.34534",
     :width=>"422.7713",
     :id=>"track_surface")
  xml.rect(
     :rx=>"114.26359",
     :style=>"fill:none;stroke:#d3040a;stroke-width:19.05940628;stroke-dasharray:%s",
     :ry=>"124.54852",
     :y=>"25.751932",
     :x=>"30.173487",
     :height=>"321.5343",
     :width=>"438.35278",
     :id=>"red_track")
  xml.rect(
     :rx=>"105.68902",
     :style=>"fill:none;stroke:#abbcf4;stroke-width:17.33102798;stroke-dasharray:%s;",
     :ry=>"111.33588",
     :y=>"43.110508",
     :x=>"47.228378",
     :height=>"287.42456",
     :width=>"405.45792",
     :id=>"blue_track")
#  xml.image(:x => "-1", :y => "-1", :height => '378', :width => '502', :"xlink:href" => "views/background_alpha2.png")
  xml.text("%s",
     :style=>"font-size:56px;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-align:start;line-height:100%;writing-mode:lr-tb;text-anchor:start;fill:black;stroke:#241c1c;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;font-family:Ubuntu-Title",
     :x=>"150.99417",
     :y=>"108.27198",
     :id=>"display_title")
}
