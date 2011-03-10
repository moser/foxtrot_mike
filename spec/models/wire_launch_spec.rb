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
end
