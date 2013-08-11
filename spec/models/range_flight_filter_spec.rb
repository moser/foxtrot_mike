require 'spec_helper'

describe RangeFlightFilter do
  let(:parent) { double("parent") }

  context "if no range is given" do
    subject { RangeFlightFilter.new(parent, nil) }

    it "should return the 40 latest flights" do
      parent.should_receive(:limit).with(40)
      subject.flights
    end
  end

  context "if range is given" do
    subject { RangeFlightFilter.new(parent, "2013-01-01_2013-01-05") }

    it "should find flights in the date range" do
      parent.should_receive(:where).with("departure_date <= ? AND departure_date >= ?", 
                                         Date.parse("2013-01-05"), Date.parse("2013-01-01"))
      subject.flights
    end
  end
end
