require File.expand_path(File.dirname(__FILE__) + '/../../spec/spec_helper')

describe PICAndXCrew do  
  it "should reference a pic" do
    r = PICAndXCrew.reflect_on_association :pic
    r.class_name.should == "Person"
    r.macro.should == :belongs_to
  end
  
  it "should reference a co pilot" do
    r = PICAndXCrew.reflect_on_association :co
    r.class_name.should == "Person"
    r.macro.should == :belongs_to
  end
end
