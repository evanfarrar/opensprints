class Race < Sequel::Model
  one_to_many :race_participations
  many_to_many :racers, :join_table => :race_participations
  many_to_one :tournament

  def finished?
    race_participations.all?(&:finish_time)
  end

  def winner
    standings = self.race_participations.sort_by { |racer| racer.finish_time||Infinity }
    standings.first
  end
 
  def unraced?
    !raced
  end

  def next_race
    (Race.filter(:raced => false, :tournament_id => tournament.pk).all - [self]).first
  end

end
