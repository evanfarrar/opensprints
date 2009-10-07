Class.new(Sequel::Migration) do
  def up
    create_table(:categories) do
      primary_key :id
      String :name, :size=>50
    end
    
    create_table(:categorizations, :ignore_index_errors=>true) do
      primary_key :id
      Integer :racer_id, :null=>false
      Integer :category_id, :null=>false
      
      index [:category_id], :name=>:index_categorizations_category
      index [:racer_id], :name=>:index_categorizations_racer
    end
    
    create_table(:race_participations, :ignore_index_errors=>true) do
      primary_key :id
      BigDecimal :finish_time, :size=>[10, 0]
      Integer :racer_id, :null=>false
      Integer :race_id, :null=>false
      
      index [:race_id], :name=>:index_race_participations_race
      index [:racer_id], :name=>:index_race_participations_racer
    end
    
    create_table(:racers) do
      primary_key :id
      String :name, :size=>50
    end
    
    create_table(:races, :ignore_index_errors=>true) do
      primary_key :id
      TrueClass :raced, :default=>false
      Integer :tournament_id
      
      index [:tournament_id], :name=>:index_races_tournament
    end
    
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
      String :name, :size=>50
    end
  end
  
  def down
    drop_table(:categories, :categorizations, :race_participations, :racers, :races, :tournament_participations, :tournaments)
  end
end
