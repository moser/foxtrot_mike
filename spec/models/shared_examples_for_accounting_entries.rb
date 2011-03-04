require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

shared_examples_for "an accounting entry factory" do
  before(:each) do 
    plane = Plane.generate!(:financial_account => FinancialAccount.generate!(:name => "plane")).id
    person = Person.generate!(:financial_account => FinancialAccount.generate!(:name => "person")).id
    person2 = Person.generate!(:financial_account => FinancialAccount.generate!(:name => "person2")).id
    wl = WireLauncher.generate!(:financial_account => FinancialAccount.generate!(:name => "wl")).id
    PlaneCostCategoryMembership.generate!(:plane_cost_category_id => (a = PlaneCostCategory.generate!.id), :plane_id => plane)
    PersonCostCategoryMembership.generate!(:person_cost_category_id => (@b = PersonCostCategory.generate!.id), :person_id => person)
    WireLauncherCostCategoryMembership.generate!(:wire_launcher_cost_category_id => (c = WireLauncherCostCategory.generate!.id), :wire_launcher_id => wl)
    r = FlightCostRule.generate!(:plane_cost_category_id => a, :person_cost_category_id => @b)
    r.flight_cost_items.create :depends_on => "duration", :value => 1
    r.flight_cost_items.create :additive_value => 10, :financial_account => fa = FinancialAccount.generate!
    r = WireLaunchCostRule.generate!(:wire_launcher_cost_category_id => c, :person_cost_category_id => @b)
    r.wire_launch_cost_items.create :value => 100
    r.wire_launch_cost_items.create :value => 10, :financial_account => fa
    
    @f = Flight.create(:plane_id => plane, :seat1_id => person, :duration => 10, :departure => DateTime.now, :controller_id => person2, :from => Airfield.generate!, :to => Airfield.generate!)
    @f.launch = WireLaunch.create(:wire_launcher_id => wl, :abstract_flight => @f)
    @f.save!
  end
  
  it "should set accounting_entries_valid to true" do
    @f.accounting_entries
    @f.accounting_entries_valid?.should be_true
  end
  
  it "should delete old accounting entries before creating new ones" do
    n = @f.accounting_entries.count
    @f.invalidate_accounting_entries
    @f.accounting_entries.count.should == n
  end
  
  it "should include accounting entries for the launch" do
    @f.launch.should_receive(:accounting_entries).and_return([1])
    @f.accounting_entries.should include(1)
  end
  
  #didn't want to setup all the stuff above in (wire_launch|tow_flight)_spec
  describe "wire_launch" do
    it "should create accounting entries" do
      @f.launch.accounting_entries.should_not be_empty
    end
  end
  
  describe "tow_flight" do
    it "should create accounting entries" do
      tow_pilot = Person.generate!.id
      tow_plane = Plane.generate!(:financial_account => FinancialAccount.generate!(:name => "tow plane")).id
      PlaneCostCategoryMembership.generate!(:plane_cost_category_id => (a = PlaneCostCategory.generate!.id), :plane_id => tow_plane)
      r = FlightCostRule.generate!(:plane_cost_category_id => a, :person_cost_category_id => @b, :flight_type => "TowFlight")
      r.flight_cost_items.create :depends_on => "duration", :value => 200
      r.flight_cost_items.create :additive_value => 10, :financial_account => fa = FinancialAccount.generate!
      @f.launch = TowFlight.create(:plane_id => tow_plane, :seat1_id => tow_pilot, :duration => 5, :to => @f.to, :abstract_flight => @f)
      @f.save!
      @f.launch.accounting_entries.should_not be_empty
    end
  end
end
