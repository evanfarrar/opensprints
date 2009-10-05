class ObsCategory
  include DataMapper::Resource
  property :id, Serial
  property :name, String

  has n, :categorizations
  has n, :obs_racers, :through => :categorizations, :mutable => true

  def to_s
    self.name
  end

  def ObsCategory.next_after(other)
    if(other)
      category = ObsCategory.first(:id.gt => other.id, :order => [:id.asc])
    else
      category = ObsCategory.first(:order => [:id.asc])
    end
    category ? category.id : nil
  end
end
