require File.expand_path(File.dirname(__FILE__) + '/../../spec/spec_helper')

describe Flight do
  it "should reference a plane" do
    r = Flight.reflect_on_association :plane
    r.class_name.should == "Plane"
    r.macro.should == :belongs_to
  end
  
  it "should reference a crew" do
    r = Flight.reflect_on_association :crew
    r.class_name.should == "Crew"
    r.macro.should == :belongs_to
  end
  
  it "should reference a launch" do
    r = Flight.reflect_on_association :launch
    r.class_name.should == "Launch"
    r.macro.should == :belongs_to
  end
  
  it "should reference two airfields" do
    r = Flight.reflect_on_association :from
    r.class_name.should == "Airfield"
    r.macro.should == :belongs_to
    r = Flight.reflect_on_association :to
    r.class_name.should == "Airfield"
    r.macro.should == :belongs_to
  end
  
  describe "arrival" do
    it "should return the arrival time" do
      f = Factory.build(:flight)
      f.arrival.should == f.departure + f.duration.minutes
    end
  end
  
  describe "crew=" do
    before(:each) do
      @f = Flight.new
      @person = Factory.create(:person)
    end
    
    it "should create a PICAndXCrew object when passed an Array" do
      @f.crew = [@person]
      @f.crew.should be_a PICAndXCrew
      @f.crew.pic.should == @person
      
      @f.crew = [@person, 2]
      @f.crew.should be_a PICAndXCrew
      @f.crew.pic.should == @person
      @f.crew.passengers.should == 2
      
      co = Factory.create(:person)
      @f.crew = [@person, co]
      @f.crew.should be_a PICAndXCrew
      @f.crew.pic.should == @person
      @f.crew.co.should == co
    end
    
    it "should create a TrainingCrew object when passed an Array with a trainee" do
      @person.stub!(:trainee? => true)
      @f.crew = [@person]
      @f.crew.should be_a TrainingCrew
      @f.crew.trainee.should == @person
      
      instructor = Factory.create(:person)
      @f.crew = [@person, instructor]
      @f.crew.should be_a TrainingCrew
      @f.crew.trainee.should == @person
      @f.crew.instructor.should == instructor
    end
    
    it "should create a PICAndXCrew object when passed a Person" do
      @f.crew = @person
      @f.crew.should be_a PICAndXCrew
      @f.crew.pic.should == @person
    end
    
    it "should create a TrainingCrew object when passed a Person that is a trainee" do
      @person.stub!(:trainee? => true)
      @f.crew = @person
      @f.crew.should be_a TrainingCrew
      @f.crew.trainee.should == @person
    end
  end
end
