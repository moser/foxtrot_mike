require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Plane do  
  it "should belong to a plane cost category" do
    r = Plane.reflect_on_association :plane_cost_category
    r.class_name.should == "PlaneCostCategory"
    r.macro.should == :belongs_to
  end
  
  it "should be revisable" do
    Plane.new.should respond_to :revisions
  end
end
