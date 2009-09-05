class Category
  include DataMapper::Resource
  property :id, Serial
  property :name, String

  has n, :categorizations
  has n, :racers, :through => :categorizations, :mutable => true

  def to_s
    self.name
  end

  def Category.next_after(other)
    if(other)
      category = Category.first(:id.gt => other.id, :order => [:id.asc])
    else
      category = Category.first(:order => [:id.asc])
    end
    category ? category.id : nil
  end
end
