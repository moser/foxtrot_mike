require 'spec_helper'

describe FlightExporter do
  describe "#to_csv" do
    it "generates a CSV string" do
      f = Flight.generate!
      e = FlightExporter.new([f])
      csv = e.to_csv
      csv.split("\n").count.should == 2
    end
  end
end
