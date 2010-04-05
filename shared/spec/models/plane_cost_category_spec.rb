require File.expand_path(File.dirname(__FILE__) + '/../../../spec/spec_helper')

describe PlaneCostCategory do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :tow_cost_rule_type => "TimeCostRule"
    }
  end
  
  it { should have_many :plane_cost_category_memberships }

  it "should create a new instance given valid attributes" do
    PlaneCostCategory.create!(@valid_attributes)
  end
end
