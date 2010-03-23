require File.expand_path(File.dirname(__FILE__) + '/../../../spec/spec_helper')

describe CrewMember do  
  it "should reference a flight" do
    r = CrewMember.reflect_on_association :flight
    r.class_name.should == "Flight"
    r.macro.should == :belongs_to
  end
  
  it "should be immutable" do
    c = CrewMember.new
    lambda {c.flight = Factory.create(:flight)}.should_not raise_error
    lambda {c.flight = Factory.create(:flight)}.should raise_error ImmutableObjectException
    lambda {c.update_attributes :flight => Factory.create(:flight)}.should raise_error ImmutableObjectException
  end
end
