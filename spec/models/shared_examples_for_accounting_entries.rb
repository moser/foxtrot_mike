require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

shared_examples_for "an accounting entry factory" do
  describe "" do
    it "" do 
      @plane = Plane.generate!
      FinancialAccountOwnership.generate!(:owner => @plane)
      @person = Person.generate!
      FinancialAccountOwnership.generate!(:owner => @person)
      person2 = Person.generate!
      FinancialAccountOwnership.generate!(:owner => person2)
      wl = WireLauncher.generate!
      FinancialAccountOwnership.generate!(:owner => wl)
      PlaneCostCategoryMembership.generate!(:plane_cost_category_id => (a = PlaneCostCategory.generate!.id), :plane_id => @plane.id)
      PersonCostCategoryMembership.generate!(:person_cost_category_id => (@b = PersonCostCategory.generate!.id), :person_id => @person.id)
      WireLauncherCostCategoryMembership.generate!(:wire_launcher_cost_category_id => (c = WireLauncherCostCategory.generate!.id), :wire_launcher_id => wl.id)
      @flru = r = FlightCostRule.generate!(:plane_cost_category_id => a, :person_cost_category_id => @b)
      r.flight_cost_items.create :depends_on => "duration", :value => 2
      r.flight_cost_items.create :additive_value => 10, :financial_account => fa = FinancialAccount.generate!
      @wiru = r = WireLaunchCostRule.generate!(:wire_launcher_cost_category_id => c, :person_cost_category_id => @b)
      r.wire_launch_cost_items.create :value => 100
      r.wire_launch_cost_items.create :value => 10, :financial_account => fa

      @xf = Flight.create(:plane_id => @plane.id, :seat1_person_id => @person.id, :departure => DateTime.now, :arrival => 10.minutes.from_now, :controller_id => person2.id, :from => Airfield.generate!, :to => Airfield.generate!)
      @lnch = @xf.launch = WireLaunch.create(:wire_launcher_id => wl.id, :abstract_flight => @xf, :operator => Person.generate!)
      @xf.save!
      @xf.accounting_entries

    #it "should create 4 accounting entries" do #launch and flight each have 1 free and 1 bound cost item
      @xf.accounting_entries.count.should == 4

    #it "should set accounting_entries_valid to true" do
      @xf.accounting_entries
      @xf.accounting_entries_valid?.should be_true

    #it "should delete old accounting entries before creating new ones" do
      n = @xf.accounting_entries.count
      @xf.invalidate_accounting_entries
      @xf.accounting_entries.count.should == n

    #launch should create entries
      @xf.launch.accounting_entries.should_not be_empty

    #it "should include accounting entries for the launch" do
      @xf.launch.should_receive(:accounting_entries).and_return([1])
      @xf.accounting_entries.should include(1)
    end

    describe "tow_flight" do
      it "should create accounting entries" do
        pm = PersonCostCategoryMembership.generate!
        person = pm.person
        plm = PlaneCostCategoryMembership.generate!
        plane = plm.plane
        tow_pilot = Person.generate!
        FinancialAccountOwnership.generate!(:owner => tow_pilot)
        tow_plane = Plane.generate!
        FinancialAccountOwnership.generate!(:owner => tow_plane)
        PlaneCostCategoryMembership.generate!(:plane_cost_category_id => (a = PlaneCostCategory.generate!.id), :plane_id => tow_plane.id)
        r = FlightCostRule.generate!(:plane_cost_category_id => a, :person_cost_category_id => pm.person_cost_category_id, :flight_type => "TowFlight")
        r.flight_cost_items.create :depends_on => "duration", :value => 200
        r.flight_cost_items.create :additive_value => 10, :financial_account => fa = FinancialAccount.generate!
        f = Flight.create(:plane_id => plane.id, :seat1_person_id => person.id, :departure => DateTime.now, :arrival => 10.minutes.from_now, :controller_id => Person.generate!.id, :from => Airfield.generate!, :to => Airfield.generate!)
        f.launch = TowFlight.create(:plane_id => tow_plane.id, :seat1_person_id => tow_pilot.id, :to => f.to, :abstract_flight => f)
        f.launch.duration = 5
        f.save!
        f.launch.accounting_entries.should_not be_empty
        f.launch.accounting_entries.select { |e| e.from_id == person.financial_account.id && e.to_id == tow_plane.financial_account.id && e.value == 1000 }.should_not be_empty
        f.launch.accounting_entries.select { |e| e.from_id == fa.id && e.to_id == tow_plane.financial_account.id && e.value == 10 }.should_not be_empty
      end
    end
  end
end
