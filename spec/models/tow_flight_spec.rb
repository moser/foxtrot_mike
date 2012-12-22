require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/shared_examples_for_accounting_entries')

describe TowFlight do
  it_behaves_like "an accounting entry factory"
  it { should have_one :abstract_flight }

  it "should reset departure, from, cost_responsible when saved" do
    t = F.create(:tow_flight)
    t.departure_date = 1.week.ago
    t.departure_i = 490 #8:10
    t.from = F.create(:airfield)
    t.save
    f = t.abstract_flight
    t.departure.should == f.departure
    t.departure_i.should == f.departure_i
    t.departure_date.should == f.departure_date
    t.cost_responsible.should == f.cost_responsible
    t.from.should == f.from
  end

  describe "accounting_entries" do
    it "should invalidate accounting_entries" do
      f = F.create(:tow_flight)
      f.accounting_entries
      f.accounting_entries_valid?.should be_true
      f.invalidate_accounting_entries
      f.accounting_entries_valid?.should be_false
    end

    it "should not invalidate accounting_entries if not editable" do
      f = F.create(:tow_flight)
      f.accounting_entries
      f.abstract_flight.should_receive(:"editable?").and_return(false)
      f.should_not_receive(:create_accounting_entries)
      f.invalidate_accounting_entries
    end

    it "should create accounting entries if invalid" do
      f = F.create(:tow_flight)
      f.should_receive(:create_accounting_entries)
      f.accounting_entries
    end
  end

end
