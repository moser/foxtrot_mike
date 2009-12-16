require File.expand_path(File.dirname(__FILE__) + '/../../spec/spec_helper')

describe Plane do  
  it "should have a relation referencing flights" do
    flights = Plane.reflect_on_association :flights
    flights.class_name.should == "Flight"
    flights.macro.should == :has_many
  end
end
