require File.expand_path(File.dirname(__FILE__) + '/../../../spec/spec_helper')

describe Flight do
  before(:each) do
    @f = Flight.new
  end
  
  it { should belong_to :plane }
  it { should belong_to :from }
  it { should belong_to :to }
  
  it { should have_many :crew_members }
  it { should have_one :launch }
  
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
    
    it "should not change the duration" do
      d = DateTime.now
      @f.departure = d
      @f.duration = 1
      @f.departure = d - 10.minutes
      @f.duration.should == 1
    end
  end
  
  describe "departure_date" do
    it "should return a date" do
      @f.departure = d = DateTime.now
      @f.departure_date.class.should == Date
    end
    
    it "should set only the date portion of departure" do
      @f.departure = dt = DateTime.now.utc
      date = Date.new(2000, 5, 29)
      @f.departure_date = date
      @f.departure.to_date.should == date
      [@f.departure.hour, @f.departure.min, @f.departure.sec].should == [dt.hour, dt.min, dt.sec]
    end
  end
  
  describe "duration" do
    it "should convert strings" do
      @f.duration = "1"
      @f.duration.should == 1
    end
    
    it "should not allow flights longer than 24 hours" do
      @f.duration = 1450
      @f.duration.should == 10
    end
    
    it "should not allow negative values" do
      @f.duration = -10
      @f.duration.should == 10
    end
  end
  
  describe "crew member factory" do
    before(:each) do
      @f = Flight.generate!
      @pilot = Person.generate!
      @pilot.stub(:trainee? => false)
      @trainee = Person.generate!
      @trainee.stub(:trainee? => true)
      @instructor = Person.generate!(:lastname => "instructor")
      @instructor.stub(:instructor? => true)
    end
    
    it "should make a single pilot a PIC" do
      @f.seat1 = @pilot
      @f.crew_members.first.should be_a PilotInCommand
    end
    
    it "should make a single pilot without license a Trainee" do
      @f.seat1 = @trainee
      @f.crew_members.first.should be_a Trainee
    end
    
    it "should make a standalone person on seat2 a PersonCrewMember" do
      @f.seat2 = @pilot
      @f.crew_members.first.should be_a PersonCrewMember
    end
    
    it "should make a instructor an Instructor when he flies with a trainee" do
      @f.seat1 = @trainee
      @f.seat2 = @instructor
      @f.crew_members.last.should be_a Instructor
    end
    
    it "should make a instructor an PersonCrewMember when he flies with a licensed pilot" do
      @f.seat1 = @pilot
      @f.seat2 = @instructor
      @f.crew_members.last.should be_a PersonCrewMember
    end
    
    it "should make anyone an PersonCrewMember when he flies with a licensed pilot" do
      @f.seat1 = @pilot
      @f.seat2 = @pilot
      @f.crew_members.last.should be_a PersonCrewMember
    end
    
    it "should check seat2 if seat1 is changed" do
      @f.seat2 = @instructor
      @f.seat2.person.stub(:instructor? => true) #hack
      @f.seat1 = @trainee
      @f.crew_members.map { |m| m.class }.should include(Instructor, Trainee)
    end
    
    it "should accept a number for seat2" do
      @f.seat2 = 3
      @f.crew_members.first.should be_a NCrewMember
    end
  end
  
  describe "cost" do
    it "should be nil if there is no crew" do
      @f.cost.should be_nil
    end
  end
  
  describe "l" do
    it "should translate FLIGHT" do
      Flight.l.should == "Flight"
      Flight.l(:duration).should == "Duration"
    end
  end
end
