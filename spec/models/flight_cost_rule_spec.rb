require 'spec_helper'

def plane_with_cost_category(cc)
  p = Plane.generate!
  p.plane_cost_category_memberships.create :plane_cost_category => cc, :valid_from => 1.day.ago
  cc.reload
  p
end

def person_with_cost_category(cc)
  p = Person.generate!
  p.person_cost_category_memberships.create :person_cost_category => cc, :valid_from => 1.day.ago
  cc.reload
  p
end

describe FlightCostRule do
  it "should apply all of its items to a flight" do
    f = Flight.generate!
    f.duration = 10
    cr = FlightCostRule.create :name => "Lala", :person_cost_category => PersonCostCategory.generate!,  
                                 :plane_cost_category => PlaneCostCategory.generate!, :valid_from => 1.day.ago
    cr.flight_cost_items.create :value => 10, :depends_on => "duration"
    cr.flight_cost_items.create :additive_value => 5, :financial_account => FinancialAccount.generate!
    cost = cr.apply_to(f)
    cost.items.size.should == 2
  end

  xit "should aggregate costs with same financial account" do
    f = Flight.generate!
    f.duration = 10
    cr = FlightCostRule.create :name => "Lala", :person_cost_category => PersonCostCategory.generate!,  
                                 :plane_cost_category => PlaneCostCategory.generate!, :valid_from => 1.day.ago
    cr.flight_cost_items.create :value => 10, :depends_on => "duration"
    cr.flight_cost_items.create :additive_value => 11
    cr.flight_cost_items.create :additive_value => 5, :financial_account => fa = FinancialAccount.generate!
    cr.flight_cost_items.create :value => 1, :depends_on => "duration", :financial_account => fa
    cost = cr.apply_to(f)
    cost.items.size.should == 2
    cost.items.find { |c| c.value == 111 && c.financial_account.nil? }.should_not be_nil
    cost.items.find { |c| c.value == 15 && c.financial_account == fa }.should_not be_nil
  end

  it "should evaluate all of its conditions" do
    f = Flight.generate!    
    cr = FlightCostRule.create :name => "Lala", :person_cost_category => PersonCostCategory.generate!,  
                                 :plane_cost_category => PlaneCostCategory.generate!, :valid_from => 1.day.ago,
                                 :flight_type => "Flight"
    cr.matches?(f).should be_false
    f.seat1 = person_with_cost_category(cr.person_cost_category)
    f.plane = plane_with_cost_category(cr.plane_cost_category)
    cr.matches?(f).should be_true
    cr.cost_rule_conditions << CostHintCondition.create(:cost_hint => ch = CostHint.generate!)
    cr.matches?(f).should be_false
    f.cost_hint = ch
    cr.matches?(f).should be_true
    f.launch = TowFlight.create :abstract_flight => f, :plane => plane_with_cost_category(cr.plane_cost_category), 
                                 :seat1 => Person.generate!, :to => Airfield.generate!, :duration => 4
    cr.matches?(f.launch).should be_false
    f.departure = 3.days.ago
    cr.matches?(f).should be_false
  end

end
