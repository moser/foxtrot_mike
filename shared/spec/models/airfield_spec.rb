require File.expand_path(File.dirname(__FILE__) + '/../../../spec/spec_helper')

describe Airfield do
  before(:each) do
    @valid_attributes = {
      :registration => 'EDDM',
      :name => 'FJS München'
    }
    @invalid_attributes = {
      :registration => 'some',
      :name => '' 
    }
  end

  it "should accept valid attributes" do
    a = Airfield.new(@valid_attributes)
    a.valid?.should be_true
  end
  
  it { should have_many :flights_from }
  it { should have_many :flights_to }
  
  it "should return registration or name when sent to_s" do
    str = "EDXY"
    p = Airfield.new :registration => str
    p.to_s.should == str
    str = "Foo"
    p = Airfield.new :name => str
    p.to_s.should == str
  end
end
