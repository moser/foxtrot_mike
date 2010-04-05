require File.expand_path(File.dirname(__FILE__) + '/../../../spec/spec_helper')

describe CrewMember do  
  it { should belong_to :flight }
  
  it "should be immutable" do
    c = CrewMember.new
    lambda {c.flight = Flight.generate!}.should_not raise_error
    lambda {c.flight = Flight.generate!}.should raise_error ImmutableObjectException
    lambda {c.update_attributes :flight => Flight.generate!}.should raise_error ImmutableObjectException
  end
end
