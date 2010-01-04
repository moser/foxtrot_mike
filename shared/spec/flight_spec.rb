require File.expand_path(File.dirname(__FILE__) + '/../../spec/spec_helper')

describe Flight do
  before(:each) do
    @f = Flight.new
  end

  it "should reference a plane" do
    r = Flight.reflect_on_association :plane
    r.class_name.should == "Plane"
    r.macro.should == :belongs_to
  end
  
  it "should reference a launch" do
    r = Flight.reflect_on_association :launch
    r.class_name.should == "Launch"
    r.macro.should == :belongs_to
  end
  
  it "should reference 2 crew members" do
    r = Flight.reflect_on_association :crew1
    r.class_name.should == "Person"
    r.macro.should == :belongs_to
    
    r = Flight.reflect_on_association :crew2
    r.class_name.should == "Person"
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
      @f.arrival.should be_nil
      @f.departure = 20.minutes.ago
      @f.duration = 10
      @f.arrival.should == @f.departure + @f.duration.minutes
    end
    
    it "should set the duration when arrival is set" do
      @f.departure = 20.minutes.ago
      @f.arrival = @f.departure + 10.minutes
      @f.duration.should == 10
    end
    
    it "should set departure and duration if there is no departure set" do
      d = DateTime.now
      @f.arrival = d
      @f.departure.should == d
      @f.duration.should == 0
    end
  end
  
  describe "departure" do
    it "should convert values to utc" do
      @f.departure = d = DateTime.now
      d = d.utc
      @f.departure.should be_utc
      @f.departure.should == d
      @f.save
      @f.reload
      @f.departure.should be_utc
      #db only saves seconds => delta should be less than 1000 ms
      (((@f.departure - d) * 86400000) < 1000).should be_true
    end
    
    it "should change the duration if it is set" do
      d = DateTime.now
      @f.departure = d
      @f.duration = 1
      @f.departure = d - 1.minute
      @f.duration.should == 2
    end
  end
end
