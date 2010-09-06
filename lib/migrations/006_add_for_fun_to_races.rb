class AddForFunToRaces < Sequel::Migration
  def up
    alter_table(:races) do
      add_column :for_fun, TrueClass, :default => false, :null => false
    end
  end

  def down
    alter_table(:races) do
      drop_column :for_fun
    end
  end
end

