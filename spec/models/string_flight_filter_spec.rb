require 'spec_helper'

describe StringFlightFilter do
  let(:parent) { double("parent") }

  context "if no filter string is given" do
    subject { StringFlightFilter.new(parent, '') }

    it "should return it's parents flights" do
      parent.should_receive(:flights)
      subject.flights
    end
  end

  context 'with a single condition' do
    subject { StringFlightFilter.new(parent, 'cost_hint: Mitflug') }

    it "should filter the parents flights by some condition" do
      col = [ double(cost_hint: ""), double(cost_hint: double(to_s: "Mitflug")) ]
      parent.should_receive(:flights).and_return(col)
      subject.flights.count.should == 1
    end
  end

  context "with more than one condition..." do
    xit "TODO"
  end
end
