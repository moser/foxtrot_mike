require File.expand_path(File.dirname(__FILE__) + '/../../spec/spec_helper')

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
    a = Airfield.new @valid_attributes
    a.should be_valid
  end
  
  it "should have two relations referencing flights" do
    flights_from = Airfield.reflect_on_association :flights_from
    flights_from.class_name.should == "Flight"
    flights_from.macro.should == :has_many
    
    flights_to = Airfield.reflect_on_association :flights_to
    flights_to.class_name.should == "Flight"
    flights_from.macro.should == :has_many
  end
end
