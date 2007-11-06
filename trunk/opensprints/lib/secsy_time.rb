class SecsyTime
  attr :mins
  attr :secs
  attr :hunds
  def initialize(mins,secs,hunds)
    @mins = mins
    @secs = secs
    @hunds = hunds
  end
  def SecsyTime.parse(str)
    mins,secshunds = str.split(':')
    four_chars = '%04i' % secshunds
    secs,hunds = four_chars[0..1].to_i,four_chars[2..3].to_i
    SecsyTime.new(mins.to_i,secs,hunds)
  end

  def in_seconds
    @mins.to_i * 60 + @secs + @hunds.to_i/100.0
  end
end
