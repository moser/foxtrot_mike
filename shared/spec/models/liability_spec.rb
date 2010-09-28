require File.expand_path(File.dirname(__FILE__) + '/../../../spec/spec_helper')

describe Liability do  
  it { should belong_to :flight }
  it { should belong_to :person }

  it { should validate_presence_of :flight }
  it { should validate_presence_of :person }
  it { should validate_presence_of :proportion }

  it { should validate_numericality_of(:proportion) }
  
  it "should delegate value to flight" do
    l = Liability.new
    flight = mock("flight")
    flight.should_receive(:value_for).with(l)
    l.stub :flight => flight
    l.value
  end
end
