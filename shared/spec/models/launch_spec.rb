require File.expand_path(File.dirname(__FILE__) + '/../../../spec/spec_helper')

describe Launch do  
  it "should reference a flight" do
    r = Launch.reflect_on_association :flight
    r.class_name.should == "Flight"
    r.macro.should == :belongs_to
  end
end
