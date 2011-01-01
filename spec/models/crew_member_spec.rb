require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CrewMember do  
  it { should belong_to :abstract_flight }
  
  it "should be immutable" do
    c = CrewMember.new
    lambda {c.abstract_flight = Flight.generate!}.should_not raise_error
    lambda {c.abstract_flight = Flight.generate!}.should raise_error ImmutableObjectException
    lambda {c.update_attributes :abstract_flight => Flight.generate!}.should raise_error ImmutableObjectException
  end
end
