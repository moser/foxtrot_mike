require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PlaneCostCategory do
  before(:all) do
    @c = PlaneCostCategory.generate!
    @p = Plane.generate!
    @c.plane_cost_category_memberships.create :plane => @p, :valid_from => 2.days.ago
    @p.reload
  end
  
  it { should have_many :plane_cost_category_memberships }
  it { should have_many :flight_cost_rules }

  it { should validate_presence_of :name }
  
  it "should find concerned accounting entry owners" do
    o = mock("owner")
    o.should_receive(:lala)
    m = mock("membership")
    m.should_receive(:find_concerned_accounting_entry_owners).and_yield(o)
    @c.stub(:plane_cost_category_memberships).and_return([m])
    @c.find_concerned_accounting_entry_owners { |o| o.lala }
  end

  it "should only match a flight when the plane is a member at the departure time" do
    f = Flight.generate!
    @c.matches?(f).should be_false
    f.plane = p = Plane.generate!
    @c.plane_cost_category_memberships.create :plane => p, :valid_from => 1.day.ago
    @c.matches?(f).should be_true
    f.plane = Plane.generate!
    @c.matches?(f).should be_false
  end
end
