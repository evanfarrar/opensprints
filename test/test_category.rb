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
    (!!c.save).should==(true)
  end

  it 'should load from the database' do
    c = Category.new(:name => "Test")
    (!!c.save).should==(true)
    Category[c.id].should.not.be.nil?
  end

  it 'should be convertible to string' do
    Category.new(:name => "Men").to_s.should=="Men"
  end

  describe "next after" do
    before do 
      Category.all.each{|c|c.destroy}
      @c1 = Category.create(:name => "one")
      @c2 = Category.create(:name => "two")
    end
    it "should know what category comes after no category" do
      Category.next_after(nil).should==(@c1.pk)
    end
    it "should know what category comes after a given category" do
      Category.next_after(@c1).should==(@c2.pk)
    end
    it "should know no category comes after a the last category" do
      Category.next_after(@c2).should==(nil)
    end
    it 'should work with no categories' do
      Category.all.each{|c|c.destroy}
      Category.next_after(nil).should==(nil)
    end
    after do
      Category.all.each{|c|c.destroy}
      Category.create(:name => "Men")
      Category.create(:name => "Women")
    end
  end

end
