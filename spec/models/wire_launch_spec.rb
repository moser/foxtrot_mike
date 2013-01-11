require 'spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/shared_examples_for_accounting_entries')

describe WireLaunch do
  it_behaves_like "an accounting entry factory"
  it { should belong_to :wire_launcher }
  it { should belong_to :operator }
  it { should have_many :accounting_entries }
  it { should have_one :abstract_flight }
  it { should have_one :manual_cost }

  it { should validate_presence_of :wire_launcher }

  it "should be able to return wire launches for a given date range" do
    a, b = 10.days.ago, 1.day.ago
    m = mock("relation")
    m.should_receive(:where).with("abstract_flights.departure_date >= ? AND abstract_flights.departure_date <= ?", a, b).and_return(m)
    m.should_receive(:select).with("wire_launches.*")
    WireLaunch.should_receive(:joins).with(:abstract_flight).and_return(m)
    WireLaunch.between(a, b)
  end

  describe "between should forward calls with nil" do
    it "to after" do
      a = 10.days.ago
      WireLaunch.should_receive(:after).with(a)
      WireLaunch.between(a, nil)
    end

    it "to before" do
      a = 10.days.ago
      WireLaunch.should_receive(:before).with(a)
      WireLaunch.between(nil, a)
    end

    it "to where(1=1)" do
      WireLaunch.should_receive(:where).with("1 = 1")
      WireLaunch.between(nil, nil)
    end
  end

  it "should be able to return wire launches after a given date" do
    a = 10.days.ago
    m = mock("relation")
    m.should_receive(:where).with("abstract_flights.departure_date >= ?", a).and_return(m)
    m.should_receive(:select).with("wire_launches.*")
    WireLaunch.should_receive(:joins).with(:abstract_flight).and_return(m)
    WireLaunch.after(a)
  end

  it "should be able to return wire launches before a given date" do
    a = 10.days.ago
    m = mock("relation")
    m.should_receive(:where).with("abstract_flights.departure_date <= ?", a).and_return(m)
    m.should_receive(:select).with("wire_launches.*")
    WireLaunch.should_receive(:joins).with(:abstract_flight).and_return(m)
    WireLaunch.before(a)
  end

  describe "accounting_entries" do
    it "should invalidate accounting_entries" do
      f = WireLaunch.generate!
      f.accounting_entries
      f.accounting_entries_valid?.should be_true
      f.invalidate_accounting_entries
      f.accounting_entries_valid?.should be_false
    end

    it "should not invalidate accounting_entries if not editable" do
      f = WireLaunch.generate!
      f.accounting_entries
      f.abstract_flight.should_receive(:"editable?").and_return(false)
      f.should_not_receive(:create_accounting_entries)
      f.invalidate_accounting_entries
    end

    it "should create accounting entries if invalid" do
      f = WireLaunch.generate!
      f.should_receive(:create_accounting_entries)
      f.accounting_entries
    end
  end

  describe "#concerned_people" do
    it "returns an array containing the operator" do
      w = F.create(:wire_launch, operator: F.create(:person))
      w.concerned_people.should be_include(w.operator)
    end
  end
end
