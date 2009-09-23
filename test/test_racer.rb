require 'lib/setup.rb'
require 'bacon'

describe 'A racer' do
  before do
    @racer = Racer.new
  end

  it 'should have a name' do
    @racer.name = "Evan F"
    @racer.name.should=="Evan F"
    @racer.to_s.should=="Evan F"
  end

  it 'should save' do
    r = Racer.new(:name => "Test")
    r.save.should==(true)
  end

  it 'should load from the database' do
    r = Racer.new(:name => "Test")
    r.save.should==(true)
    Racer.get(r.id).should.not.be.nil?
  end

  it "should have categories" do
    c = Category.create(:name => "Men")
#    @racer.categories << c

    @racer.categorizations.new(:category => c)
    @racer.categorizations.map(&:category).should.include? c
    @racer.save.should==(true)
  end
end
