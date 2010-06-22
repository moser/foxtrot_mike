require File.expand_path(File.dirname(__FILE__) + '/../../../spec/spec_helper')

describe TowLaunch do
  it { should belong_to :abstract_flight }
  
  it "should return available tow_cost_rules" do
    plane_m = Factory.create(:plane_cost_category_membership, :plane_cost_category => PlaneCostCategory.generate!(:tow_cost_rule_type => "TowCostRule"))
    person_m = Factory.create(:person_cost_category_membership)
    r = TowCostRule.create :person_cost_category => person_m.person_cost_category,
                           :plane_cost_category => plane_m.plane_cost_category,
                           :name => "r"
    f = Factory.create(:flight, :seat1 => person_m.person)
    l = TowLaunch.create :abstract_flight => f, :tow_flight => TowFlight.create(:plane => plane_m.plane)   
    l.available_tow_cost_rules.should == [r]
  end
  
  it "should return [] if there is no cost_responsible" do
    f = Factory.create(:flight)
    l = TowLaunch.create :abstract_flight => f, :tow_flight => TowFlight.create
    l.available_tow_cost_rules.should == []
  end
  
  it "should return available tow_levels" do
    l = TowLaunch.new
    a = mock("tow_cost_rule a", :tow_levels => [1, 2])
    b = mock("tow_cost_rule a", :tow_levels => [5, 6])
    l.stub(:available_tow_cost_rules => [a, b])
    l.available_tow_levels.should == [1, 2, 5, 6]
  end
  
  describe "tow_flight_attributes" do
    #TODO
  end
  
end
