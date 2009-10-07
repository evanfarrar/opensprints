class CreateTournaments < Sequel::Migration
  def up
    create_table(:tournament_participations, :ignore_index_errors=>true) do
      primary_key :id
      TrueClass :eliminated
      Integer :racer_id, :null=>false
      Integer :tournament_id, :null=>false
      
      index [:racer_id], :name=>:index_tournament_participations_racer
      index [:tournament_id], :name=>:index_tournament_participations_tournament
    end
    
    create_table(:tournaments) do
      primary_key :id
      String :name, :size=> 140
    end
  end

  def down
    drop_table(:tournaments)
    drop_table(:tournament_participations)
  end
end

