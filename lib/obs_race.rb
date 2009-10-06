class ObsRace
  include DataMapper::Resource
  property :id, Serial
  property :raced, Boolean, :default => false
  has n, :obs_race_participations
  belongs_to :tournament, :nullable => true

  def racers
    obs_race_participations.map(&:obs_racer)
  end

  def unraced?
    !raced?
  end

  def next_race
    (tournament.obs_races.all(:raced => false) - [self]).first
  end

  def winner
    standings = self.obs_race_participations.sort_by { |racer| racer.finish_time||Infinity }
    standings.first
  end

  def finished?
    obs_race_participations.all?(&:finish_time)
  end

  def names
    racers.map(&:name)
  end

  def names_to_colors
    racers.join("|vs.|").split('|').zip($BIKES.join("|white|").split('|'))
  end
end
