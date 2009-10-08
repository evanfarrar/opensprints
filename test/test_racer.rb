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
    (!!r.save).should==(true)
  end

  it 'should load from the database' do
    r = Racer.new(:name => "Test")
    (!!r.save).should==(true)
    Racer[r.pk].should.not.be.nil?
  end

  it "should have categories" do
    c = Category.create(:name => "Men")
#    @racer.categories << c

    @racer.save
    Categorization.create(:category => c, :racer => @racer)
    @racer.reload.categorizations.map(&:category).should.include? c
    @racer.categories.should.include? c
  end

  it "should know the best time ever" do
    racer = Racer.create
    [7.0, 12.0, 2.7, 10.0].each do |time|
      race = Race.create
      RaceParticipation.create(:finish_time => time, :race => race, :racer => racer)
    end
    racer.best_time.should==(2.7)
  end
end
