class Category < Sequel::Model
  def to_s
    self.name
  end

  def Category.next_after(other)
    if(other)
      category = Category.filter(:id > other.pk).order(:id).first
    else
      category = Category.order(:id).first
    end
    category ? category.pk : nil
  end

end
