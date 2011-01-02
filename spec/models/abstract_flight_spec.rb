require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AbstractFlight do
  before(:each) do
    @f = Flight.new
  end
  
  it { should belong_to :plane }
  it { should belong_to :from }
  it { should belong_to :to }
  
  it { should have_many :crew_members }
  it { should belong_to :launch }
  
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
    
    it "should set departure and duration if departure is nil" do
      f = AbstractFlight.new
      f.arrival = 1.minute.ago
      f.departure.should_not be_nil
      f.duration.should == 0
    end
  end
  
  describe "departure" do
    it "should set sec to 0" do
      @f.departure = d = DateTime.now
      @f.departure.sec.should == 0
    end
    
    it "should convert values to utc" do
      f = Flight.spawn
      f.departure = d = DateTime.now
      d = d.utc
      f.departure.should be_utc
      (f.departure - d).abs.should < 60
      f.save
      f.reload
      f.departure.should be_utc
      (f.departure - d).abs.should < 60
    end
    
    it "should change the duration" do
      @f.departure = DateTime.now
      @f.duration = 1
      @f.departure = @f.departure - 10.minutes
      @f.duration.should == 11
    end
  end
  
  describe "arrival_time" do
    it "should return minutes since midnight" do
      @f.departure_date = DateTime.now
      @f.duration = 122
      @f.arrival_time.should == 122
    end
    
    it "should not fail when passed nil and set duration = 0" do
      @f.duration = 5
      Proc.new { @f.arrival_time = nil }.should_not raise_error
      @f.duration.should == -1
    end
    
    it "should set the duration" do
      @f.departure_date = DateTime.now
      @f.arrival_time = 122
      @f.duration.should == 122
    end
    
    it "should set arrival to the next day if arrival is lower than departure" do
      @f.departure = DateTime.new(2010, 6, 30, 20, 0, 0, 0)
      Proc.new { @f.arrival_time = 65 }.should_not raise_error
      @f.duration.should == 305
    end
  end
  
  describe "departure_date" do
    it "should return a date" do
      @f.departure = d = DateTime.now
      @f.departure_date.class.should == Date
    end
    
    it "should set only the date portion of departure" do
      @f.departure = dt = DateTime.now.utc
      @f.departure_date = date = Date.new(2000, 5, 29)
      @f.departure.to_date.should == date
      [@f.departure.hour, @f.departure.min].should == [dt.hour, dt.min]
    end
    
    it "should set departure if departure is nil" do
      f = AbstractFlight.new
      f.departure_date = date = Date.new(2000, 5, 29)
      f.departure.to_date.should == date
      [f.departure.hour, f.departure.min].should == [0, 0]
    end
  end
  
  describe "departure_time" do
    it "should return minutes since midnight" do
      @f.departure = d = DateTime.now.utc
      @f.departure_time.should == d.min + d.hour * 60
    end
    
    it "should set just the time" do
      @f.departure_time = 62
      [@f.departure.hour, @f.departure.min].should == [1, 2]
    end
  end
  
  describe "duration" do
    it "should be negative on a new record" do
      @f.duration.should < 0  
    end
    
    it "should convert strings" do
      @f.duration = "1"
      @f.duration.should == 1
    end
    
    it "should not allow flights longer than 24 hours" do
      @f.duration = 1450
      @f.duration.should == 10
    end
    
    it "should allow negative values and set -1" do
      @f.duration = -10
      @f.duration.should == -1
    end
  end
  
  describe "landed?" do
    it "should be false if duration negative" do
      @f.landed?.should == false
    end
    
    it "should be true if duration non-negative" do
      @f.duration = 0
      @f.landed?.should == true
      @f.duration = 100
      @f.landed?.should == true
    end
  end
  
  describe "crew member factory" do
    before(:each) do
      @f = AbstractFlight.spawn
      @pilot = Person.generate!
      @pilot.stub(:trainee? => false)
      @trainee = Person.generate!
      @trainee.stub(:trainee? => true)
      @instructor = Person.generate!(:lastname => "instructor")
      @instructor.stub(:instructor? => true)
    end
    
    it "should accept ids" do
      @f.should_receive(:seat1=).with(1)
      @f.seat1_id = 1
      
      @f.should_receive(:seat2=).with(1)
      @f.seat2_id = 1
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
    
    it "should remove a crew member if passed nil" do
      @f.seat1 = @pilot
      @f.seat1 = nil
      @f.crew_members.size.should == 0
      
      @f.seat2 = @pilot
      @f.seat2 = nil
      @f.crew_members.size.should == 0
    end

    it "should remove a crew member if passed id=''" do
      @f.seat1 = @pilot
      @f.seat1_id = ''
      @f.crew_members.size.should == 0
      
      @f.seat2 = @pilot
      @f.seat2_id = ''
      @f.crew_members.size.should == 0
    end
    
    describe "pic" do
      it "should return seat1 if no trainee" do
        @f.seat1 = @pilot
        @f.pic.should == @f.seat1
      end
      
      it "should return seat1 if a solo trainee" do
        @f.seat1 = @trainee
        @f.pic.should == @f.seat1
      end
      
      it "should return seat2 if trainee and instructor" do
        @f.seat1 = @trainee
        @f.seat2 = @instructor
        @f.pic.should == @f.seat2
      end
    end

    it "should make the crew members persistent" do
      @f.seat1 = @pilot
      @f.seat1.should_not be_nil
    end
  end
  
  describe "crew_members_attributes" do
    
  end
  
  describe "launch_attributes" do
    
  end
  
  describe "shared_attributes" do
    it "should contain launch_attributes" do
      @f.launch = WireLaunch.create
      @f.shared_attributes.keys.should include :launch_attributes
    end
    
    it "should contain crew_members_attributes" do
      @f.shared_attributes.keys.should include :crew_members_attributes
    end
  end
  
  describe "cost" do
    it "should be nil if there is no crew" do
      @f.cost.should be_nil
    end
  end
  
  describe "group_id" do
    it "should change when departure_date, seat1 or seat2 change" do
      f = Flight.create
      s = f.group_id
      f.departure_date = 1.day.ago
      f.group_id.should_not == s
      s = f.group_id
      f.seat1 = Person.generate!
      f.group_id.should_not == s
      s = f.group_id
      f.seat2 = Person.generate!
      f.group_id.should_not == s
      s = f.group_id
      f.seat1 = Person.generate!
      f.group_id.should_not == s
    end
  end

  describe "l" do
    it "should translate FLIGHT" do
      AbstractFlight.l.should == "Abstract flight"
      AbstractFlight.l(:duration).should == "Duration"
    end
  end
end
