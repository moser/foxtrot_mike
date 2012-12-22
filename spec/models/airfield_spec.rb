# encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Airfield do
  before(:all) do
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
  
  it "should return a sunrise/sunset calculator" do
    a = Airfield.generate!(:lat => 11.0, :long => 13.0)
    a.srss.should respond_to(:sunrise)
    a.srss.should respond_to(:sunset)
  end
end
