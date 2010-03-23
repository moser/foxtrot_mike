require File.expand_path(File.dirname(__FILE__) + '/../../../spec/spec_helper')

describe Person do  
  it "should tell if she is a trainee" do
    p = Factory.build(:person)
    p.trainee?(nil).should == false
  end
  
  it "should concat it's name" do
    p = Factory.build(:person)
    p.name.should == "bar foo"
  end
  
  it "should match it's name" do
    p = Factory.build(:person)
    p.name?("bar foo").should be_true
    p.name?("BAr fOO").should be_true
  end
  
  it "should return name when sent to_s" do
    p = Factory.build(:person)
    p.to_s.should == "bar foo"
  end
end
