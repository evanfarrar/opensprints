class Categorization
  include DataMapper::Resource
  property :id, Serial

  belongs_to :obs_category
  belongs_to :obs_racer
end
