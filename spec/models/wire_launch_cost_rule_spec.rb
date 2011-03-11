require 'spec_helper'

def wire_launcher_with_cost_category(cc)
  p = WireLauncher.generate!
  p.wire_launcher_cost_category_memberships.create :wire_launcher_cost_category => cc, :valid_from => 1.day.ago
  cc.reload
  p
end

def person_with_cost_category(cc)
  p = Person.generate!
  p.person_cost_category_memberships.create :person_cost_category => cc, :valid_from => 1.day.ago
  cc.reload
  p
end

describe WireLaunchCostRule do
  it "should find concerned accounting entry owners" do
    r = WireLaunchCostRule.create :name => "Lala", :person_cost_category => PersonCostCategory.generate!,  
                                 :wire_launcher_cost_category => WireLauncherCostCategory.generate!, :valid_from => 1.day.ago
    m = mock("relation")
    m.should_receive(:between).with(r.valid_from, nil)
    r.wire_launcher_cost_category.should_receive(:find_concerned_accounting_entry_owners).and_yield(m)
    r.find_concerned_accounting_entry_owners
  end
  
  it "should apply all of its items to a wire launch" do
    l = WireLaunch.generate!
    cr = WireLaunchCostRule.create :name => "Lala", :person_cost_category => PersonCostCategory.generate!,  
                                 :wire_launcher_cost_category => WireLauncherCostCategory.generate!, :valid_from => 1.day.ago
    cr.wire_launch_cost_items.create :value => 10
    cr.wire_launch_cost_items.create :value => 5, :financial_account => FinancialAccount.generate!
    cost = cr.apply_to(l.abstract_flight)
    cost.items.size.should == 2
  end

  it "should evaluate all of its conditions" do
    l = WireLaunch.generate!
    cr = WireLaunchCostRule.create :name => "Lala", :person_cost_category => PersonCostCategory.generate!,  
                                 :wire_launcher_cost_category => WireLauncherCostCategory.generate!, :valid_from => 1.day.ago
    cr.matches?(l.abstract_flight).should be_false
    l.abstract_flight.seat1 = person_with_cost_category(cr.person_cost_category)
    l.wire_launcher = wire_launcher_with_cost_category(cr.wire_launcher_cost_category)
    l.save
    l.reload
    cr.matches?(l.abstract_flight).should be_true
    cr.cost_rule_conditions << CostHintCondition.create(:cost_hint => ch = CostHint.generate!)
    cr.matches?(l.abstract_flight).should be_false
    l.abstract_flight.cost_hint = ch
    cr.matches?(l.abstract_flight).should be_true
    l.abstract_flight.departure = 3.days.ago
    cr.matches?(l.abstract_flight).should be_false
  end

end
