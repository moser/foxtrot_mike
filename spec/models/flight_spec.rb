require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Flight do
  before(:each) do
    @valid_attributes = {
      :duration => 1,
      :departure => Time.now
    }
    @f = Flight.generate!
  end
  
  it { should have_many :liabilities }
  it { should belong_to :cost_hint }
  it { should belong_to :accounting_session }

  describe "liabilities" do
    it "should create a default liability if none other present" do
      f = Flight.generate!(:seat1 => Person.generate)
      f.liabilities_with_default.count.should == 1
    end
  end
  
  describe "liabilities_attributes" do
    it "TODO"
  end
  
  describe "cost" do    
    it "should calculate the values for liabilities" do
      @f.liabilities.create(:person => Person.generate, :proportion => 100)
      @f.should_receive(:free_cost_sum).at_least(:once).and_return(400)
      @f.proportion_for(@f.liabilities.first).should == 1.0
      @f.value_for(@f.liabilities.first).should == 400
      
      @f.liabilities << Liability.new(:person => Person.generate, :proportion => 100)
      @f.proportion_for(@f.liabilities.first).should == 0.5
      @f.value_for(@f.liabilities.first).should == 200
    end
  end
  
  describe "shared_attributes" do 
    it "should contain liabilities_attributes" do
      @f.shared_attributes.keys.should include :liabilities_attributes
    end
  end
  
  describe "l" do
    it "should translate FLIGHT" do
      Flight.l.should == "Flug"
      Flight.l(:duration).should == "Dauer"
    end
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
    r = FlightCostRule.generate!(:plane_cost_category_id => a, :person_cost_category_id => b)
    r.flight_cost_items.create :depends_on => "duration", :value => 1
    r.flight_cost_items.create :additive_value => 10, :financial_account => fa = FinancialAccount.generate!
    r = WireLaunchCostRule.generate!(:wire_launcher_cost_category_id => c, :person_cost_category_id => b)
    r.wire_launch_cost_items.create :value => 100
    r.wire_launch_cost_items.create :value => 10, :financial_account => fa
    
    f = Flight.create(:plane_id => plane, :seat1_id => person, :duration => 10, :departure => DateTime.now)
    f.launch = WireLaunch.create(:wire_launcher_id => wl, :abstract_flight => f)
    f.save
    
    Liability.create(:flight_id => f.id, :person_id => person, :proportion => 1)
    p f.accounting_entries
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

  it "should be editable until it belongs to a finished accounting session" do
    f = Flight.generate!
    f.editable?.should be_true
    f.accounting_session = AccountingSession.new
    f.editable?.should be_true
    f.accounting_session = AccountingSession.new(:finished_at => 1.hour.ago)
    f.editable?.should be_false
  end

  it "should deny any changes when not editable" do
    f = Flight.generate!
    f.accounting_session = a = AccountingSession.generate!
    f.save
    a.update_attributes(:finished_at => 1.hour.ago)
    f = Flight.find(f.id)
    f.save.should be_false
    f.errors.keys.should include(:base)
    lambda { f.save! }.should raise_error
    f.save(:validate => false).should be_false
    f.errors.keys.should include(:base)
  end
end
