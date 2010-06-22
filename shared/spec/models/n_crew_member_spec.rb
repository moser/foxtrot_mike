require File.expand_path(File.dirname(__FILE__) + '/../../../spec/spec_helper')

describe NCrewMember do  
  it "should be immutable" do
    c = NCrewMember.new
    lambda {c.n = 2}.should_not raise_error
    lambda {c.n = 1}.should raise_error ImmutableObjectException
    lambda {c.update_attributes :n => 1}.should raise_error ImmutableObjectException
  end
  
  it "should respond to to_s" do
    NCrewMember.new(:n => 1).to_s.should == "+1"
  end
end
