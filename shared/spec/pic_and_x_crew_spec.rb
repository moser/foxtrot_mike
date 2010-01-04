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
  
  it "should return the PIC for seat1" do
    p = Factory.build(:person)
    c = PICAndXCrew.new :pic => p
    c.seat1.should == p
  end
  
  it "should return the PNF for seat2" do
    p = Factory.build(:person)
    c = PICAndXCrew.new :co => p
    c.seat2.should == p 
  end
  
  it "should return the passengers count for seat2" do
    c = PICAndXCrew.new :passengers => 2
    c.seat2.should == 2
  end
end
