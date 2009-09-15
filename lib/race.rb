class Race
  include DataMapper::Resource
  property :id, Serial
  property :raced, Boolean, :default => false
  has n, :race_participations
  belongs_to :tournament

  def racers
    race_participations.map(&:racer)
  end

  def unraced?
    !raced?
  end

  def next_race
    (tournament.races.all(:raced => false) - [self]).first
  end

  def winner
    standings = self.race_participations.sort_by { |racer| racer.finish_time||Infinity }
    standings.first
  end

  def finished?
    race_participations.all?(&:finish_time)
  end

  def names
    racers.map(&:name)
  end

  def names_to_colors
    racers.join("|vs.|").split('|').zip($BIKES.join("|white|").split('|'))
  end
end
