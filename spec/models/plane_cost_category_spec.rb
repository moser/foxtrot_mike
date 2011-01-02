require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PlaneCostCategory do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :tow_cost_rule_type => "TimeCostRule"
    }
  end
  
  it { should have_many :plane_cost_category_memberships }
  it { should have_many :flight_cost_rules }

  it { should validate_presence_of :name }

  it "should create a new instance given valid attributes" do
    PlaneCostCategory.create!(@valid_attributes)
  end

  it "should only match a flight when the plane is a member at the departure time" do
    c = PlaneCostCategory.generate!
    f = Flight.generate!
    c.matches?(f).should be_false
    f.plane = p = Plane.generate!
    c.plane_cost_category_memberships.create :plane => p, :valid_from => 1.day.ago
    c.matches?(f).should be_true
    f.plane = Plane.generate!
    c.matches?(f).should be_false
  end
end
