require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PlaneCostCategoryMembership do
  before(:each) do
    @valid_attributes = {
      :valid_from => 1.day.ago,
      :plane => Plane.generate!,
      :plane_cost_category => PlaneCostCategory.generate!
    }
  end

  it "should create a new instance given valid attributes" do
    PlaneCostCategoryMembership.create!(@valid_attributes)
  end

  it { should belong_to :plane_cost_category }
  it { should belong_to :plane }
  
  it { should ensure_immutability_of(:plane) }
  it { should ensure_immutability_of(:plane_cost_category) }
  
  it { should validate_presence_of :plane_cost_category }
  it { should validate_presence_of :plane }

  
  it "should find concerned accounting entry owners" do
    m = PlaneCostCategoryMembership.create!(@valid_attributes)
    rel = mock("relation")
    rel.should_receive(:between).with(m.valid_from, nil)
    wl = mock("plane")
    wl.should_receive("find_concerned_accounting_entry_owners").and_yield(rel)
    m.should_receive(:plane).and_return(wl)
    m.find_concerned_accounting_entry_owners { |r| r }
  end
end
