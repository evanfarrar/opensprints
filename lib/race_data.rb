
#########################################################################
#RaceData contains some useful methods for parsing and storing race data packets from the Arduino
#
#The packets are in the structure !TIME@DATA#
#
#TIME is an string representing 32-bit millis(),
#DATA is a block of characters encoding one HEX nibble per byte, 
#to which we've added 128 to remain string-friendly
#The first data byte corresponds to the tick status at TIME
#The second to TIME + RACE_FRAME_LENGTH (typically 2ms here)
#Subsequent correspond to TIME + x, where x is the index of the byte in the data section 
#
#Each HEX nibble represents the tick status of each sensor during 
#the 1-2ms period to which it corresponds
#
#parseStringToRaceData takes this data and puts the times into arrays for each racer
#redTicks[0,5,9,12] indicates that Red ticked at 0, 10, 18 and 24 milliseconds, respectively
#redTicks.size * rollercircumference == current distance for red
#
#
#
#
#
#MILLIS_PER_FRAME should correspond to the Arduino -- currently ~2ms, but
#can be a float to make minor corrections...

MILLIS_PER_FRAME = 2.0

class RaceData
  
  attr_accessor :racers
  
  def initialize()
    @data = [128,129,128,128,129,130,128,135,143,143,'#'.to_i]
    @rawdata = []
    @testinput = "!0@" + @data.pack('c*')
    @racers = [[],[],[],[]]
    @test = false
  end
  
  def printRaceData()
    puts "Red:",@racers[0].join(' ')
    puts "Blue:",@racers[1].join(' ')
    puts "Green:",@racers[2].join(' ')
    puts "Yellow:",@racers[3].join(' ')
  end
  
  def parseStringToRaceData(aString)
    aString = @testinput if @test == true
    if aString =~ /!(\d+)@([a-q]*)#/ # returns the time in $1, and the data in $2
      time = $1.to_i
      @rawdata = $2.unpack('C*')
      @rawdata.each_with_index{|data,x| 
          if (data - ?a)[0] == 1 
            @racers[0].push(time+(x*MILLIS_PER_FRAME))
          end
          
          if (data - ?a)[1] == 1 
            @racers[1].push(time+x*MILLIS_PER_FRAME)
          end
          
          if (data - ?a)[2] == 1 
            @racers[2].push(time+x*MILLIS_PER_FRAME)
          end
         
          if (data - ?a)[3] == 1 
            @racers[3].push(time+x*MILLIS_PER_FRAME)
          end
        }
      #print(@rawdata, "\n")
      #printRaceData()
      #debug("test")
    end
  end

  
  
end
