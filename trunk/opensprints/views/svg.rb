xml.svg(:height => "741", :width => "993", :viewBox => "0 0 499 378",
        :xmlns => "http://www.w3.org/2000/svg",
        :'xmlns:xlink'=>"http://www.w3.org/1999/xlink",
        :version => "1.0",
        :baseProfile=>"full") {
  xml.defs{
    xml.style(:type=>'text/css'){ xml.cdata!(@stylishness) }
  }
  xml.rect(
     :style=>"fill:black;stroke:none;stroke-width:0.95099998;",
     :id=>"background",
     :width=>"501.12021",
     :height=>"374.30038",
     :x=>"0.081355505",
     :y=>"0.077205971")
  xml.rect(:style=>"fill:#73d83e;stroke:none;stroke-width:0.95099998;",
     :id=>"field",
     :width=>"488.198",
     :height=>"364.28113",
     :x=>"6.2120686",
     :y=>"5.4431815",
     :rx=>"12",
     :ry=>"12")
  xml.text("%s",
     :style=>"font-size:56px;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-align:start;line-height:100%;writing-mode:lr-tb;text-anchor:start;fill:black;stroke:#241c1c;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;font-family:Ubuntu-Title",
     :x=>"150.99417",
     :y=>"108.27198",
     :id=>"display_title")
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
  xml.g(:id=>"track_markings"){
    xml.rect(
       :width=>"422.7713",
       :height=>"305.34534",
       :x=>"38.320702",
       :y=>"34.814106",
       :ry=>"118.27761",
       :style=>"fill:none;stroke:black;stroke-width:2.58699989;",
       :rx=>"110.20203")
    xml.rect(
       :width=>"457.75491",
       :height=>"338.50665",
       :x=>"20.776157",
       :y=>"18.176891",
       :ry=>"131.12288",
       :style=>"fill:none;stroke:black;stroke-width:2.83431506;",
       :rx=>"119.32105")
    xml.rect(
       :width=>"388.39374",
       :height=>"272.18262",
       :x=>"55.15303",
       :y=>"51.946342",
       :ry=>"105.43181",
       :style=>"fill:none;stroke:black;stroke-width:2.3410697;",
       :rx=>"101.24097")
    xml.path(
       :d=>"M 105.08534,24.335342 L 119.05622,57.743977",
       :style=>"fill:none;fill-rule:evenodd;stroke:black;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;")
    xml.g(:class=>'distance_marking'){
      xml.path(:d=>"M 249.04618,17.046185 L 249.04618,51.06225")
      xml.path(:d=>"M 247.2239,323.19076 L 247.2239,355.99197")
      xml.path(:d=>"M 257.64405,355.61805 L 257.73716,316.13512")
    }
    xml.path(
       :d=>"M 252.08333,356.5994 L 252.08333,323.19076",
       :style=>"fill:none;fill-rule:evenodd;stroke:black;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;")
    xml.text("#{RACE_DISTANCE}m",
       :y=>"313.17331",
       :x=>"256.13306",
       :style=>"font-size:12px;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-align:start;line-height:125%;writing-mode:lr-tb;text-anchor:start;fill:white;stroke:black;stroke-width:0.40000001;stroke-linecap:butt;stroke-linejoin:miter;")
  }
}
