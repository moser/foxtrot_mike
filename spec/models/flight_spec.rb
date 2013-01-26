require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/shared_examples_for_accounting_entries')

describe Flight do
  before(:all) do
    @person1 = F.create(:person)
    @person2 = F.create(:person)
  end

  it_behaves_like "an accounting entry factory"

  it { should have_many :liabilities }
  it { should belong_to :cost_hint }
  it { should belong_to :accounting_session }

  describe "liabilities" do
    it "should create a default liability if none other present" do
      f = F.create(:flight)
      f.liabilities_with_default.count.should == 1
    end
  end

  describe "liabilities_attributes" do
    it "should work :D" do
      f = F.create(:flight, :liabilities_attributes => [{ :person => @person1, :proportion => 3 },
                                                        { :person => @person2, :proportion => 1}])
      f.liabilities.count.should == 2
      f.liabilities.map(&:proportion).sort.should == [1,3]
    end
  end

  describe "cost" do
    it "should calculate the values for liabilities" do
      f = F.create(:flight)
      f.liabilities.create(:person => @person1, :proportion => 100)
      f.should_receive(:free_cost_sum).at_least(:once).and_return(400)
      f.proportion_for(f.liabilities.first).should == 1.0
      f.value_for(f.liabilities.first).should == 400

      f.liabilities << Liability.new(:person => @person2, :proportion => 100)
      f.proportion_for(f.liabilities.first).should == 0.5
      f.value_for(f.liabilities.first).should == 200
    end
  end

  describe "l" do
    it "should translate FLIGHT" do
      Flight.l.should == "Flug"
      Flight.l(:duration).should == "Dauer"
    end
  end

  describe "accounting_entries" do
    it "should invalidate accounting_entries" do
      f = F.create(:flight)
      f.accounting_entries
      f.accounting_entries_valid?.should be_true
      launch = mock("launch")
      launch.should_receive(:invalidate_accounting_entries).at_least(:once)
      launch.stub(:abstract_flight_changed)
      f.should_receive(:launch).at_least(:once).and_return(launch)
      f.invalidate_accounting_entries
      f.accounting_entries_valid?.should be_false
    end

    it "should not invalidate accounting_entries if not editable" do
      f = F.create(:flight)
      f.accounting_entries
      f.should_receive(:"editable?").and_return(false)
      f.should_not_receive(:launch)
      f.should_not_receive(:create_accounting_entries)
      f.invalidate_accounting_entries
    end

    it "should create accounting entries if invalid" do
      f = F.create(:flight)
      f.update_attribute :accounting_entries_valid, false
      f.should_receive(:create_accounting_entries)
      f.accounting_entries
    end
  end

  it "should be editable until it belongs to a finished accounting session" do
    f = F.create(:flight)
    f.editable?.should be_true
    f.accounting_session = AccountingSession.new
    f.editable?.should be_true
    f.accounting_session = AccountingSession.new(:finished_at => 1.hour.ago)
    f.editable?.should be_false
  end

  it "should deny any changes when not editable" do
    f = F.create(:flight)
    f.accounting_session = a = F.create(:accounting_session) 
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
