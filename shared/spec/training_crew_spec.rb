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
end
