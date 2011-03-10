require 'spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/shared_examples_for_accounting_entries')

describe WireLaunch do
  it_behaves_like "an accounting entry factory"
  it { should belong_to :wire_launcher }
  it { should have_many :accounting_entries }
  it { should have_one :abstract_flight }
  it { should have_one :manual_cost }
  
  it "should be able to return wire launches for a given date range" do
    a, b = 10.days.ago, 1.day.ago
    m = mock("relation")
    m.should_receive(:where).with("abstract_flights.departure >= ? AND abstract_flights.departure < ?", a, b)
    WireLaunch.should_receive(:joins).with(:abstract_flight).and_return(m)
    WireLaunch.between(a, b)
  end
  
  it "should be able to return wire launches after a given date" do
    a = 10.days.ago
    m = mock("relation")
    m.should_receive(:where).with("abstract_flights.departure >= ?", a)
    WireLaunch.should_receive(:joins).with(:abstract_flight).and_return(m)
    WireLaunch.after(a)
  end
  
  it "should be able to return wire launches before a given date" do
    a = 10.days.ago
    m = mock("relation")
    m.should_receive(:where).with("abstract_flights.departure < ?", a)
    WireLaunch.should_receive(:joins).with(:abstract_flight).and_return(m)
    WireLaunch.before(a)
  end
  
  describe "accounting_entries" do
    it "should invalidate accounting_entries and start a delayed job for their creation" do
      f = WireLaunch.generate!
      f.accounting_entries
      f.accounting_entries_valid?.should be_true
      f.should_receive(:delay) { m = mock("delay proxy"); m.should_receive(:create_accounting_entries); m }
      f.invalidate_accounting_entries
      f.accounting_entries_valid?.should be_false
    end
    
    it "should create accounting entries without a delayed job, if called with delayed = false" do
      f = WireLaunch.generate!
      f.accounting_entries
      f.accounting_entries_valid?.should be_true 
      f.should_not_receive(:delay)
      f.should_receive(:create_accounting_entries)
      f.invalidate_accounting_entries(false)
      f.accounting_entries_valid?.should be_false #create_accounting_entries was mocked
    end
    
    it "should not invalidate accounting_entries if not editable" do
      f = WireLaunch.generate!
      f.accounting_entries
      f.abstract_flight.should_receive(:"editable?").exactly(2).times.and_return(false)
      f.should_not_receive(:delay) 
      f.should_not_receive(:create_accounting_entries)
      f.invalidate_accounting_entries(true)
      f.invalidate_accounting_entries(false)
    end
    
    it "should create accounting entries if invalid" do
      f = WireLaunch.generate!
      f.should_receive(:create_accounting_entries)
      f.accounting_entries
    end  
  end
end
