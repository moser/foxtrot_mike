require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Flight do
  before(:each) do
    @valid_attributes = {
      :duration => 1,
      :departure => Time.now
    }
  end

  it "should create a new instance given valid attributes" do
    Flight.create(@valid_attributes)
  end
  
  it "should be revisable" do
    Flight.new.should respond_to :versions
  end

  it "should create bookings" do
    plane = Plane.generate!(:financial_account => FinancialAccount.generate!(:name => "plane")).id
    person = Person.generate!(:financial_account => FinancialAccount.generate!(:name => "person")).id
    person2 = Person.generate!(:financial_account => FinancialAccount.generate!(:name => "person2")).id
    wl = WireLauncher.generate!(:financial_account => FinancialAccount.generate!(:name => "wl")).id
    PlaneCostCategoryMembership.generate!(:plane_cost_category_id => (a = PlaneCostCategory.generate!.id), :plane_id => plane)
    PersonCostCategoryMembership.generate!(:person_cost_category_id => (b = PersonCostCategory.generate!.id), :person_id => person)
    WireLauncherCostCategoryMembership.generate!(:wire_launcher_cost_category_id => (c = WireLauncherCostCategory.generate!.id), :wire_launcher_id => wl)
    TimeCostRule.generate!(:plane_cost_category_id => a, :person_cost_category_id => b)
    WireLaunchCostRule.generate!(:wire_launcher_cost_category_id => c, :person_cost_category_id => b)
    
    f = Flight.create(:plane_id => plane, :seat1_id => person, :duration => 10, :departure => DateTime.now)
    f.launch = WireLaunch.create(:wire_launcher_id => wl)
    f.save
    
    Liability.create(:flight_id => f.id, :person_id => person, :proportion => 1)
      
    p f.bookings
  end
  
  it "should have a complete history" do
    f = Flight.create
    f.update_attribute :plane_id, Plane.generate!.id
    sleep 1
    f.seat1 = Person.generate!
    sleep 1
    f.seat2 = Person.generate!
    sleep 1
    f.seat2 = 1
    sleep 1
    f.update_attribute :from_id, Airfield.generate!.id
#    f.history.each { |r|
#      puts r.revisable_current_at
#      puts r.class
#    }
    #TODO
  end
end
