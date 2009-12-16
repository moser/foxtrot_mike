require File.expand_path(File.dirname(__FILE__) + '/../../spec/spec_helper')

describe Person do  
  it "should tell if she is a trainee" do
    p = Factory.build(:person)
    p.trainee?(nil).should == false
  end
  
  it "should concat it's name" do
    p = Factory.build(:person)
    p.name.should == "bar foo"
  end
end
