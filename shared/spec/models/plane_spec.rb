require File.expand_path(File.dirname(__FILE__) + '/../../../spec/spec_helper')

describe Plane do  
  it { should have_many :flights }
  it { should have_many :plane_cost_category_memberships }
  
  it "should return registration when sent to_s" do
    str = "D-ZZZZ"
    p = Plane.new :registration => str
    p.to_s.should == str
  end
  
  it "should have some flags" do
    p = Plane.new :has_engine => true, :can_tow => true, :can_fly_without_engine => false
    p.engine_duration_possible?.should be_false
  end
end
