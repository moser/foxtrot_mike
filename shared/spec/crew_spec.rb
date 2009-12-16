require File.expand_path(File.dirname(__FILE__) + '/../../spec/spec_helper')

describe Crew do  
  it "should reference a flight" do
    r = Crew.reflect_on_association :flight
    r.class_name.should == "Flight"
    r.macro.should == :has_one
  end
end
