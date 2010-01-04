require File.expand_path(File.dirname(__FILE__) + '/../../spec/spec_helper')

describe Crew do  
  it "should reference a flight" do
    r = Crew.reflect_on_association :flight
    r.class_name.should == "Flight"
    r.macro.should == :has_one
  end
  
  describe "Crew::build" do
    before(:each) do
      @person = Factory.create(:person)
    end
    
    it "should create a PICAndXCrew object when passed an Array" do
      crew = Crew.build [@person]
      crew.should be_a PICAndXCrew
      crew.pic.should == @person
      
      crew = Crew.build [@person, 2]
      crew.should be_a PICAndXCrew
      crew.pic.should == @person
      crew.passengers.should == 2
      
      co = Factory.create(:person)
      crew = Crew.build [@person, co]
      crew.should be_a PICAndXCrew
      crew.pic.should == @person
      crew.co.should == co
    end
    
    it "should create a TrainingCrew object when passed an Array with a trainee" do
      @person.stub!(:trainee? => true)
      crew = Crew.build [@person]
      crew.should be_a TrainingCrew
      crew.trainee.should == @person
      
      instructor = Factory.create(:person)
      crew = Crew.build [@person, instructor]
      crew.should be_a TrainingCrew
      crew.trainee.should == @person
      crew.instructor.should == instructor
    end
    
    it "should create a PICAndXCrew object when passed a Person" do
      crew = Crew.build @person
      crew.should be_a PICAndXCrew
      crew.pic.should == @person
    end
    
    it "should create a TrainingCrew object when passed a Person that is a trainee" do
      @person.stub!(:trainee? => true)
      crew = Crew.build @person
      crew.should be_a TrainingCrew
      crew.trainee.should == @person
    end
  end
end
