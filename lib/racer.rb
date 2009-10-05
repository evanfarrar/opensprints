class Racer < Sequel::Model
  one_to_many :categorizations
  def to_s
    name
  end
end
