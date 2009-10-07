class CreateRaces < Sequel::Migration
  def up
    create_table :races do
      primary_key :id
      TrueClass :raced, :default => false
      Integer :tournament_id
    end
    create_table(:race_participations, :ignore_index_errors=>true) do
      primary_key :id
      BigDecimal :finish_time, :size=>[10, 0]
      Integer :racer_id, :null=>false
      Integer :race_id, :null=>false

      index [:race_id], :name=>:index_race_participations_race
      index [:racer_id], :name=>:index_race_participations_racer
    end
  end

  def down
    drop_table(:races)
    drop_table(:race_participations)
  end
end

