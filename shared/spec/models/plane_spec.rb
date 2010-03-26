require File.expand_path(File.dirname(__FILE__) + '/../../../spec/spec_helper')

describe Plane do  
  it "should have a relation referencing flights" do
    flights = Plane.reflect_on_association :flights
    flights.class_name.should == "Flight"
    flights.macro.should == :has_many
  end
  
  it "should belong to a plane cost category" do
    r = Plane.reflect_on_association :plane_cost_category_memberships
    r.class_name.should == "PlaneCostCategoryMembership"
    r.macro.should == :has_many
  end
  
  it "should return registration when sent to_s" do
    str = "D-ZZZZ"
    p = Plane.new :registration => str
    p.to_s.should == str
  end
  
  it "should have some flags" do
    p = Plane.new :has_engine => true, :can_tow => true, :can_fly_without_engine => false
    p.engine_duration?.should be_false
  end
end
