require File.expand_path(File.dirname(__FILE__) + '/../../spec/spec_helper')

describe TrainingCrew do  
  it "should reference a trainee" do
    r = TrainingCrew.reflect_on_association :trainee
    r.class_name.should == "Person"
    r.macro.should == :belongs_to
  end
  
  it "should reference an instructor" do
    r = TrainingCrew.reflect_on_association :instructor
    r.class_name.should == "Person"
    r.macro.should == :belongs_to
  end
  
  it "should return the trainee for seat1" do
    p = Factory.build(:person)
    c = TrainingCrew.new :trainee => p
    c.seat1.should == p
  end
  
  it "should return the instructor for seat2" do
    p = Factory.build(:person)
    c = TrainingCrew.new :instructor => p
    c.seat2.should == p 
  end
end
