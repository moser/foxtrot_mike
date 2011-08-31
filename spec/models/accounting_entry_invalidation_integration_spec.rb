require 'spec_helper'

describe "Accounting entry invalidation" do
  describe "wire launch and friends" do    
    def check_change
      old_ids = @f.launch.accounting_entries.map(&:id)
      yield
      @f.reload
      @f.launch.accounting_entries.map(&:id).should_not include(*old_ids)
    end
    
    it "invalidate accounting_entries" do
      @wm = WireLauncherCostCategoryMembership.generate!(:valid_to => nil)
      @wl = @wm.wire_launcher
      @pm = PersonCostCategoryMembership.generate!(:valid_to => nil)
      @p = @pm.person
      @cr = WireLaunchCostRule.create!(:wire_launcher_cost_category => @wm.wire_launcher_cost_category,
                                         :person_cost_category => @pm.person_cost_category,
                                         :name => "foo", :valid_from => 1.month.ago)
      @cr.wire_launch_cost_items.create(:name => "1", :value => 10)
      @f = Flight.generate!(:seat1_id => @p.id)
      @f.launch = WireLaunch.create!(:abstract_flight => @f, :wire_launcher => @wl)
      
      [ @wm, @wl, @pm, @p, @cr, @f ].each { |o| o.reload }
      
      #WireLaunchCostRule
      check_change do 
        @cr.update_attribute :valid_to, 1.year.from_now
      end
      check_change do 
        @cr.wire_launch_cost_items.create(:name => "2", :value => 1, :financial_account => FinancialAccount.generate!)
      end
      i = @cr.wire_launch_cost_items.create(:name => "2", :value => 1, :financial_account => FinancialAccount.generate!)
      check_change do 
        i.update_attributes(:value => 2)
      end
      
      #WireLauncherCostCategoryMembership
      check_change do
        @wm.update_attribute :valid_to, 1.year.from_now
      end
         
      #WireLauncher
      check_change do
        @wl.financial_account_ownerships.create(:valid_from => 1.month.from_now, :financial_account => FinancialAccount.generate!)
      end
      
      #WireLaunch
      check_change do
        launch = @f.launch
        launch.wire_launcher = WireLauncher.generate!
        launch.save
      end
    end
  end

  describe "flight and friends" do    
    def check_change
      old_ids = @f.accounting_entries.map(&:id)
      yield
      @f.reload
      @f.accounting_entries.map(&:id).should_not include(*old_ids)
    end
    
    it "invalidate accounting entries" do
      @plm = PlaneCostCategoryMembership.generate!(:valid_to => nil)
      @plane = @plm.plane
      @pm = PersonCostCategoryMembership.generate!(:valid_to => nil)
      @person = @pm.person
      @cr = FlightCostRule.create!(:plane_cost_category => @plm.plane_cost_category,
                                     :person_cost_category => @pm.person_cost_category,
                                     :name => "foo", :valid_from => 1.month.ago,
                                     :flight_type => "Flight")
      @cr.flight_cost_items.create!(:value => 10, :depends_on => "duration")
      @f = Flight.generate!(:plane_id => @plane.id, :seat1_id => @person.id, :duration => 20)

      [ @plm, @plane, @pm, @person, @cr, @f ].each { |o| o.reload }
      
      #FlightCostRule
      check_change do
        @cr.update_attribute :valid_to, 1.year.from_now
      end
      check_change do
        @cr.flight_cost_items.create(:name => "2", :value => 1, :financial_account => FinancialAccount.generate!)
      end
      i = @cr.flight_cost_items.create(:name => "2", :value => 1, :financial_account => FinancialAccount.generate!)
      check_change do
        i.update_attributes(:value => 2)
      end
      
      #PlaneCostCategoryMembership
      check_change do
        @plm.update_attribute :valid_to, 1.year.from_now
      end
      check_change do
        PlaneCostCategoryMembership.generate! :plane => @plane, :valid_from => 1.year.ago
      end
      
      #Plane
      check_change do
        @plane.financial_account_ownerships.create(:valid_from => 1.month.from_now, :financial_account => FinancialAccount.generate!)
      end
      
      #PersonCostCategoryMembership
      check_change do
        @pm.update_attribute :valid_to, 1.year.from_now
      end
      check_change do
        PersonCostCategoryMembership.generate! :person => @person, :valid_from => 1.year.ago
      end
      
      #Person
      check_change do
        @person.financial_account_ownerships.create(:valid_from => 1.month.from_now, :financial_account => FinancialAccount.generate!)
      end
      
      #Flight
      check_change do
        @f.update_attribute :duration, 100
      end
      check_change do
        @f.update_attribute :plane, Plane.generate!
      end
      check_change do
        @f.seat1 = Person.generate!
      end
      check_change do
        @f.liabilities.create :person => Person.generate!, :proportion => 1
      end
      check_change do
        @f.liabilities.clear
      end
    end
  end
  
  describe "tow flight and friends" do  
    def check_change
      old_ids = @l.accounting_entries.map(&:id)
      yield
      @l.reload
      @l.accounting_entries.map(&:id).should_not include(*old_ids)
    end
    
    it "invalidate accounting entries" do
      @plm = PlaneCostCategoryMembership.generate!(:valid_to => nil)
      @tplane = @plm.plane
      @pm = PersonCostCategoryMembership.generate!(:valid_to => nil)
      @person = @pm.person
      @other_person = Person.generate!
      @cr = FlightCostRule.create!(:plane_cost_category => @plm.plane_cost_category,
                                     :person_cost_category => @pm.person_cost_category,
                                     :name => "foo", :valid_from => 1.month.ago,
                                     :flight_type => "TowFlight")
      @cr.flight_cost_items.create!(:value => 10, :depends_on => "duration")
      @f = Flight.generate!(:seat1_id => @person.id, :duration => 20)
      @l = TowFlight.generate!(:plane => @tplane, :seat1_id => @other_person.id, :abstract_flight => @f, :duration => 5)
      
      [ @plm, @tplane, @pm, @person, @other_person, @cr, @f, @l ].each { |o| o.reload }
      
      #FlightCostRule
      check_change do
        @cr.update_attribute :valid_to, 1.year.from_now
      end
      check_change do
        @cr.flight_cost_items.create(:name => "2", :value => 1, :financial_account => FinancialAccount.generate!)
      end
      i = @cr.flight_cost_items.create(:name => "2", :value => 1, :financial_account => FinancialAccount.generate!)
      check_change do
        i.update_attributes(:value => 2)
      end
      
      #PlaneCostCategoryMembership
      check_change do
        @plm.update_attribute :valid_to, 1.year.from_now
      end
      check_change do
        PlaneCostCategoryMembership.generate! :plane => @tplane, :valid_from => 1.year.ago
      end
      
      #Plane
      check_change do
        @tplane.financial_account_ownerships.create(:valid_from => 1.month.from_now, :financial_account => FinancialAccount.generate!)
      end
      
      #TowFlight
      check_change do
        @l.update_attribute :duration, 10
      end
      check_change do
        @l.update_attribute :plane, Plane.generate!
      end
    end
  end
end
