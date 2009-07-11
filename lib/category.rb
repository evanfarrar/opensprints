class Category
  include DataMapper::Resource
  property :id, Serial
  property :name, String

  has n, :categorizations
  has n, :racers, :through => :categorizations, :mutable => true

  def to_s
    self.name
  end
end
