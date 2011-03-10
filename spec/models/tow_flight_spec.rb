require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/shared_examples_for_accounting_entries')

describe TowFlight do
  it_behaves_like "an accounting entry factory"
  it { should have_one :abstract_flight }
  
  it "should reset departure, from, cost_responsible when saved" do
    t = TowFlight.spawn :abstract_flight => f = Flight.generate!
    t.departure = 1.week.ago
    t.from = Airfield.generate!
    t.save
    t.departure.should == f.departure
    t.cost_responsible.should == f.cost_responsible
    t.from.should == f.from
  end
  
  describe "accounting_entries" do
    it "should invalidate accounting_entries and start a delayed job for their creation" do
      f = TowFlight.generate!
      f.accounting_entries
      f.accounting_entries_valid?.should be_true
      f.should_receive(:delay) { m = mock("delay proxy"); m.should_receive(:create_accounting_entries); m }
      f.invalidate_accounting_entries
      f.accounting_entries_valid?.should be_false
    end
    
    it "should create accounting entries without a delayed job, if called with delayed = false" do
      f = TowFlight.generate!
      f.accounting_entries
      f.accounting_entries_valid?.should be_true 
      f.should_not_receive(:delay)
      f.should_receive(:create_accounting_entries)
      f.invalidate_accounting_entries(false)
      f.accounting_entries_valid?.should be_false #create_accounting_entries was mocked
    end
    
    it "should not invalidate accounting_entries if not editable" do
      f = TowFlight.generate!
      f.accounting_entries
      f.abstract_flight.should_receive(:"editable?").exactly(2).times.and_return(false)
      f.should_not_receive(:delay) 
      f.should_not_receive(:create_accounting_entries)
      f.invalidate_accounting_entries(true)
      f.invalidate_accounting_entries(false)
    end
    
    it "should create accounting entries if invalid" do
      f = TowFlight.generate!
      f.should_receive(:create_accounting_entries)
      f.accounting_entries
    end  
  end
  
end
