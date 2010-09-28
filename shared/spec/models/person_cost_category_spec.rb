require File.expand_path(File.dirname(__FILE__) + '/../../../spec/spec_helper')

describe PersonCostCategory do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
    }
  end
  
  it { should have_many :person_cost_category_memberships }
  it { should have_many :time_cost_rules }
  it { should have_many :tow_cost_rules }
  it { should have_many :wire_launch_cost_rules }
  it { should validate_presence_of :name }

  it "should create a new instance given valid attributes" do
    PersonCostCategory.create!(@valid_attributes)
  end
end
