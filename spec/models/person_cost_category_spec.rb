require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PersonCostCategory do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
    }
  end
  
  it { should have_many :person_cost_category_memberships }
  it { should have_many :flight_cost_rules }
  it { should have_many :wire_launch_cost_rules }
  it { should validate_presence_of :name }

  it "should create a new instance given valid attributes" do
    PersonCostCategory.create!(@valid_attributes)
  end

  it "should match a flight when the cost responsible is a member at the departure time" do
    c = PersonCostCategory.generate!
    f = Flight.generate!
    c.matches?(f).should be_false 
    f.seat1_person = p = Person.generate!
    c.person_cost_category_memberships.create :person => p, :valid_from => 1.day.ago
    c.matches?(f).should be_true
    f.departure = 2.days.ago
    c.matches?(f).should be_false 
  end
end
