class Racer < Sequel::Model
  one_to_many :categorizations
  many_to_many :categories, :join_table => :categorizations
  def to_s
    name
  end
end
