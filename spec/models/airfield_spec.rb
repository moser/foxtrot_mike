# encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Airfield do
  before(:each) do
    @valid_attributes = {
      :registration => 'EDDM',
      :name => 'FJS München'
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
    p = Airfield.new :name => "Abc", :registration => "XXXX"
    p.to_s.should == "XXXX"
  end
  
  it "should only shared some attributes" do
    Airfield.shared_attribute_names.should == [ :id, :registration, :name ]
  end
  
  it "should return shared_attributes" do
    Airfield.generate!.shared_attributes.keys.to_set.should == Airfield.shared_attribute_names.map { |n| n.to_s }.to_set
  end
end
