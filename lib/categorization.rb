class Categorization
  include DataMapper::Resource
  property :id, Serial

  belongs_to :category
  belongs_to :racer
end
