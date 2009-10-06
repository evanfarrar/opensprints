class CreateCategorizations < Sequel::Migration
  def up
    create_table(:categorizations, :ignore_index_errors=>true) do
      primary_key :id
      Integer :racer_id, :null=>false
      Integer :category_id, :null=>false
      
      index [:category_id], :name=>:index_categorizations_category
      index [:racer_id], :name=>:index_categorizations_racer
    end
  end

  def down
    drop_table(:categorizations)
  end
end

