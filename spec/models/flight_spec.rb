require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/shared_examples_for_accounting_entries')

describe Flight do
  it_behaves_like "an accounting entry factory"
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
  
  describe "accounting_entries" do
    it "should invalidate accounting_entries and start a delayed job for their creation" do
      f = Flight.generate!
      f.accounting_entries
      f.accounting_entries_valid?.should be_true
      f.should_receive(:delay) { m = mock("delay proxy"); m.should_receive(:create_accounting_entries); m }
      launch = mock("launch")
      launch.should_receive(:invalidate_accounting_entries)
      f.should_receive(:launch).at_least(1).and_return(launch)
      f.invalidate_accounting_entries
      f.accounting_entries_valid?.should be_false
    end
    
    it "should create accounting entries if invalid" do
      f = Flight.generate!
      f.should_receive(:create_accounting_entries)
      f.accounting_entries
    end  
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
