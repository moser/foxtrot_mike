require File.expand_path(File.dirname(__FILE__) + '/../../../spec/spec_helper')

describe PlaneCostCategoryMembership do
  before(:each) do
    @valid_attributes = {
      :valid_from => 1.day.ago
    }
  end

  it "should create a new instance given valid attributes" do
    PlaneCostCategoryMembership.create!(@valid_attributes)
  end

  it { should belong_to :plane_cost_category }
  it { should belong_to :plane }
end
