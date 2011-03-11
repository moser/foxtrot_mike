require 'spec_helper'

describe "Accounting entry invalidation" do
  describe "wire launch" do
    before(:each) do
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
      [ @wm, @wl, @pm, @p, @cr, @f ].each { |e| e.reload }
    end
    
    def check_change
      old_ids = @f.launch.accounting_entries.map(&:id)
      yield
      @f.reload
      @f.launch.accounting_entries.map(&:id).should_not include(*old_ids)
    end
    
    describe "WireLaunchCostRule" do
      it "should invalidate accounting entries when changed" do
        check_change do 
          @cr.update_attribute :valid_to, 1.year.from_now
        end
      end
      
      it "should invalidate accounting entries when a cost item is added" do
        check_change do 
          @cr.wire_launch_cost_items.create(:name => "2", :value => 1, :financial_account => FinancialAccount.generate!)
        end
      end
    end
    
    describe "WireLauncherCostCategoryMembership" do
      it "should invalidate accounting entries when changed" do
        check_change do
          @wm.update_attribute :valid_to, 1.year.from_now
        end
      end
    end
    
    describe "WireLauncher" do
      it "should invalidate accounting entries when financial account is changed" do
        check_change do
          @wl.financial_account_ownerships.create(:valid_from => 1.month.from_now, :financial_account => FinancialAccount.generate!)
        end
      end
    end
    
    describe "WireLaunch" do
      it "should invalidate accounting entries when changed" do
        check_change do
          launch = @f.launch
          launch.wire_launcher = WireLauncher.generate!
          launch.save
        end
      end
    end
  end
end
