require 'lib/setup.rb'
require 'bacon'

describe 'A category' do
  before do
    @category = Category.new
  end

  it 'should have a name' do
    @category.name = "Women"
    @category.name.should=="Women"
  end

  it 'should save' do
    c = Category.new(:name => "Test")
    c.save.should==(true)
  end

  it 'should load from the database' do
    c = Category.new(:name => "Test")
    c.save.should==(true)
    Category.get(c.id).should.not.be.nil?
  end

  it 'should be convertible to string' do
    Category.new(:name => "Men").to_s.should=="Men"
  end

end
