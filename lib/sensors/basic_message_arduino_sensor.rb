module NewFirmware
  def send_length(ticks)
    begin
      Timeout.timeout(1.0){
        @f.flush
        @f.puts "!l:#{ticks}"
        log "setting length"
        @length_status = nil
        while !@length_status do
          line = @f.readline
          @length_status = line if line =~ /^L:#{ticks}/
        end
        log "length status: #{@length_status}"
      }
    rescue Timeout::Error
      log "Timeout setting length"
      raise ErrorSettingLength
    end
    send_countdown
  end

  def send_countdown
    begin
      Timeout.timeout(1.0){
        @f.flush
        @f.puts "!c:4"
        log "setting countdown"
        @countdown_status = nil
        while !@countdown_status do
          line = @f.readline
          @countdown_status = line if line =~ /^C:4/
        end
        log "countdown status: #{@countdown_status}"
      }
    rescue Timeout::Error
      log "Timeout setting countdown"
      raise ErrorSettingLength
    end
  end

  def start
    @t.kill if @t
    @t = Thread.new(Thread.current) do |parent|
      @f.puts "!g"
      Thread.current["racers"] = [[],[],[],[]]
      Thread.current["finish_times"] = []
      Thread.current["false_start"] = nil
      @f.flush
      while true do
        l = @f.readline
        if l=~/:/
          if l =~ /0:/
            Thread.current["racers"][0] =  [0] * l.gsub(/0: /,'').to_i
          end
          if l =~ /1:/
            Thread.current["racers"][1] =  [1] * l.gsub(/1: /,'').to_i
          end
          if l =~ /2:/
            Thread.current["racers"][2] =  [2] * l.gsub(/2: /,'').to_i
          end
          if l =~ /3:/
            Thread.current["racers"][3] =  [3] * l.gsub(/3: /,'').to_i
          end
          if l =~ /0f:/
            Thread.current["finish_times"][0] = l.gsub(/0f: /,'').to_i
          end
          if l =~ /1f:/
            Thread.current["finish_times"][1] = l.gsub(/1f: /,'').to_i
          end
          if l =~ /2f:/
            Thread.current["finish_times"][2] = l.gsub(/2f: /,'').to_i
          end
          if l =~ /3f:/
            Thread.current["finish_times"][3] = l.gsub(/3f: /,'').to_i
          end
          if l =~ /t:/
            Thread.current["time"] = l.gsub(/t: /,'').to_i
          end
          if l =~ /F:/
            Thread.current["false_start"] = l.gsub(/F:/,'').to_i
          end
        end
        log l
      end
    end
    self
  end

  def finish_times
    @t['finish_times'] || []
  end

  def racers
    @t['racers'] || [[],[],[],[]]
  end

  def time
    @t['time'] || 0
  end

  def false_start
    @t&&@t['false_start']
  end

  def stop
    @f.puts '!s'
    @f.flush
    @t.kill
  end

  def handshake()
    @handshake ||= 0
    @handshake = @handshake <= 2**16-1 ? @handshake+1 : 0
    begin
    Timeout.timeout(1.0){
      @f.flush
      @f.puts "!a:#{@handshake}"
      log "ping: #{@handshake}"
      handshake_status = nil
      while !handshake_status do
        line = @f.readline
        handshake_status = line if line =~ /^A:#{@handshake}/
      end
      log "pong: #{handshake_status}"
    }
    rescue Timeout::Error
      log "the arduino is unplugged!"
      raise MissingArduinoError
    end
    true
  end

  private
  #OS X doesn't have a raw terminal puts-ing.
  def log(message)
    if RUBY_PLATFORM =~ /darwin/
      @logger ||= Logger.new
      @logger.puts message
    else
      puts message
    end
  end

  class Logger
    def initialize
      @file = File.open "/tmp/opensprintslog", "w"
    end

    def puts(message)
      @file.puts message
      @file.flush
    end
  end
end

module LegacyFirmware
  def send_length(ticks)
    begin
      Timeout.timeout(1.0){
        @f.flush
        @f.putc ?l
        @f.putc(ticks % 256)
        @f.putc(ticks / 256)
        @f.putc ?\r
        puts "setting length"
        @length_status = @f.readline
        puts "length status: #{@length_status}"
      }
    rescue Timeout::Error
      puts "Timeout setting length"
    else
      #TODO raise an ErrorReceivingTickLength and catch it in the app like
      #   we do with a missing arduino error.
      #raise @length_status unless @length_status=~/OK/
    end
  end

  def start
    @t.kill if @t
    @t = Thread.new do
      @f.putc 'g'
      Thread.current["racers"] = [[],[],[],[]]
      Thread.current["finish_times"] = []
      @f.flush
      while true do
        l = @f.readline
        if l=~/:/
          if l =~ /0:/
            Thread.current["racers"][0] =  [0] * l.gsub(/0: /,'').to_i
          end
          if l =~ /1:/
            Thread.current["racers"][1] =  [1] * l.gsub(/1: /,'').to_i
          end
          if l =~ /2:/
            Thread.current["racers"][2] =  [2] * l.gsub(/2: /,'').to_i
          end
          if l =~ /3:/
            Thread.current["racers"][3] =  [3] * l.gsub(/3: /,'').to_i
          end
          if l =~ /0f:/
            Thread.current["finish_times"][0] = l.gsub(/0f: /,'').to_i
          end
          if l =~ /1f:/
            Thread.current["finish_times"][1] = l.gsub(/1f: /,'').to_i
          end
          if l =~ /2f:/
            Thread.current["finish_times"][2] = l.gsub(/2f: /,'').to_i
          end
          if l =~ /3f:/
            Thread.current["finish_times"][3] = l.gsub(/3f: /,'').to_i
          end
          if l =~ /t:/
            Thread.current["time"] = l.gsub(/t: /,'').to_i
          end
        end
        puts l
      end
    end
    self
  end

  def finish_times
    @t['finish_times'] || []
  end

  def racers
    @t['racers'] || [[],[],[],[]]
  end

  def time
    @t['time'] || 0
  end

  def stop
    @f.puts 's'
    @f.flush
    @t.kill
  end
end


#Arduino: a sensor written for the arduino open source hardware.
class Sensor
  attr_accessor :queue
  attr_accessor :version
  def initialize(filename=nil)
    raise MissingArduinoError unless File.writable?(filename)
    #HACK oogity boogity magic happens here:
    if RUBY_PLATFORM =~ /darwin/
      @f = File.open(filename, 'w+')
      `stty -f #{filename} cs8 115200 ignbrk -brkint -icrnl -imaxbel -opost -onlcr -isig -icanon -iexten -echo -echoe -echok -echoctl -echoke -noflsh -ixon -crtscts`
    else
      `stty -F #{filename} cs8 115200 ignbrk -brkint -icrnl -imaxbel -opost -onlcr -isig -icanon -iexten -echo -echoe -echok -echoctl -echoke -noflsh -ixon -crtscts`
      @f = File.open(filename, 'w+')
    end

    get_version

    ticks = ($RACE_DISTANCE / $ROLLER_CIRCUMFERENCE).floor
    send_length(ticks)
  end

  def get_version
    begin
      Timeout.timeout(2){
        sleep(1)
        @f.flush
        @f.puts "!v"
        @f.flush
        puts "getting version"
        version = @f.readline
        puts "version: #{version}"
        if version =~ /^V:/
          @version = version.sub(/^V:/,'').to_f
          extend NewFirmware
        else
          extend LegacyFirmware
        end
      }
    rescue Timeout::Error
      puts "Timeout getting version"
      extend LegacyFirmware
    end
  end

end
