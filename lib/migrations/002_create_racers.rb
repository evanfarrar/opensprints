class CreateRacers < Sequel::Migration
  def up
    create_table :racers do
      primary_key :id
      String :name
      DateTime :created_at
    end
  end

  def down
    drop_table(:racers)
  end
end

