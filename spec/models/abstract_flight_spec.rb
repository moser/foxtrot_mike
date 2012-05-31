require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AbstractFlight do
  it { should belong_to :plane }
  it { should belong_to :from }
  it { should belong_to :to }
  
  it { should have_many :crew_members }
  it { should have_many :accounting_entries }
  it { should belong_to :launch }
  
  it "should be able to return flights for a given date range" do
    a, b = 10.days.ago, 1.day.ago
    AbstractFlight.should_receive(:where).with("departure_date >= ? AND departure_date < ?", a, b)
    AbstractFlight.between(a, b)
  end
  
  describe "between should forward calls with nil" do
    it "to after" do
      a = 10.days.ago
      AbstractFlight.should_receive(:after).with(a)
      AbstractFlight.between(a, nil)
    end
    
    it "to before" do
      a = 10.days.ago
      AbstractFlight.should_receive(:before).with(a)
      AbstractFlight.between(nil, a)
    end
    
    it "to where(1=1)" do
      AbstractFlight.should_receive(:where).with("1 = 1")
      AbstractFlight.between(nil, nil)
    end
  end
  
  it "should be able to return flights after a given date" do
    a = 10.days.ago
    AbstractFlight.should_receive(:where).with("departure_date >= ?", a)
    AbstractFlight.after(a)
  end
  
  it "should be able to return flights before a given date" do
    a = 10.days.ago
    AbstractFlight.should_receive(:where).with("departure_date < ?", a)
    AbstractFlight.before(a)
  end
  
  describe "departure_date" do
    it "should return a date" do
      f = Flight.new
      f.departure = DateTime.now
      f.departure_date.class.should == Date
      f.departure_date = DateTime.now
      f.departure_date.class.should == Date
    end
  end
  
  describe "departure" do
    before(:each) do
      @f = Flight.new
    end

    it "should set the departure_date" do
      @f.departure = 2.days.from_now
      @f.departure_date.should == 2.days.from_now.to_date
    end
    
    it "should return a DateTime" do
      @f.departure.should be_a(DateTime)
      @f.departure_i = 10
      @f.departure.should be_a(DateTime)
    end
    
    it "should add departure_i minutes to departure_date" do
      @f.departure_i = 100
      @f.departure.hour.should == 1
      @f.departure.min.should == 40
    end
    
    it "should accept a string" do
      @f.departure = "10"
      @f.departure_i.should == 10
      @f.departure = "8:21"
      @f.departure_i.should == 501
    end
  end
  
  describe "arrival" do
    before(:each) do
      @f = Flight.new
    end

    it "should return a DateTime" do
      @f.departure_i = 0
      @f.arrival.should be_nil
      @f.arrival_i = 10
      @f.arrival.should be_a(DateTime)
    end
    
    it "should add arrival_i minutes to departure_date" do
      @f.departure_i = 0
      @f.arrival_i = 100
      @f.arrival.hour.should == 1
      @f.arrival.min.should == 40
    end
    
    it "should add a day if arrival is before departure" do
      @f.departure_i = 100
      @f.arrival_i = 60
      @f.arrival.should > @f.departure
    end
    
    it "should accept a string" do
      @f.arrival = "10"
      @f.arrival_i.should == 10
      @f.arrival = "8:21"
      @f.arrival_i.should == 501
    end
  end
  
  describe "duration" do
    it "should be -1 if arrival or departure is unset" do
      f = Flight.new
      f.duration.should == -1
      f.departure = 1
      f.duration.should == -1
      f.departure = -1
      f.arrival = 10
      f.duration.should == -1
    end
    
    it "should be the difference between arrival and departure" do
      f = Flight.new
      f.departure = 10
      f.arrival = 20
      f.duration.should == 10
    end
    
    it "should be positive and less than 1440 when arrival is before departure" do
      f = Flight.new
      f.departure = 1430 #23:50
      f.arrival = 10 #0:10
      f.duration.should == 20
    end
  end

  describe "#engine_duration" do
    before(:each) do
      @f = Flight.new
      @f.departure = 0
      @f.arrival = 10
      @f.plane = Plane.spawn
    end

    it "should default to 0 if plane has no engine" do
      @f.plane.stub(:has_engine => false)
      @f.engine_duration.should == 0
    end

    it "should default to duration if plane cannot fly without engine" do
      @f.plane.stub(:can_fly_without_engine => false)
      @f.plane.stub(:has_engine => true)
      @f.engine_duration.should == 10
    end

    it "should default to duration if plane has default_engine_duration_to_duration set" do
      @f.plane.stub(:default_engine_duration_to_duration => true)
      @f.plane.stub(:can_fly_without_engine => true)
      @f.plane.stub(:has_engine => true)
      @f.engine_duration.should == 10
    end
  end
  
  describe "landed?" do
    before(:each) do
      @f = Flight.new
    end

    it "should be false if arrival_i is negative" do
      @f.landed?.should == false
    end
    
    it "should be true if arrival_i > 0" do
      @f.departure_i = 1
      @f.arrival_i = 1
      @f.landed?.should == true
      @f.duration = 100
      @f.landed?.should == true
    end
  end
  
  describe "crew member factory" do
    before(:all) do
      @pilot = F.create(:person)
      @trainee = F.create(:person)
      @instructor = F.create(:person)
    end

    before(:each) do
      @f = F.create(:flight)
      @pilot.stub(:trainee? => false)
      @trainee.stub(:trainee? => true)
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

    it "should create a unknown crew member when passed 'unknown'" do
      @f.seat1 = "unknown"
      @f.crew_members.first.should be_a UnknownCrewMember
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
      @f = F.build(:flight, :seat1 => nil)
      @f.seat2 = 3
      @f.crew_members.first.should be_a NCrewMember
      @f.crew_members.first.n.should == 3
      @f.seat2 = nil
      @f.seat2 = "+2"
      @f.crew_members.first.should be_a NCrewMember
      @f.crew_members.first.n.should == 2
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
  
  describe "cost" do
    it "should be nil if there is no crew" do
      f = Flight.new
      f.cost.should be_nil
    end
  end
  
  describe "aggregation_id" do
    it "should change when plane, departure_date, seat1 or seat2 change" do
      f = F.build(:flight)
      f.from = f.to
      s = f.generate_aggregation_id
      f.plane = F.create(:plane)
      f.generate_aggregation_id.should_not == s
      f.departure_date = 1.day.ago
      f.generate_aggregation_id.should_not == s
      s = f.generate_aggregation_id
      f.seat1 = F.create(:person)
      f.generate_aggregation_id.should_not == s
      s = f.generate_aggregation_id
      f.seat2 = F.create(:person)
      f.generate_aggregation_id.should_not == s
      s = f.generate_aggregation_id
      f.seat1 = F.create(:person)
      f.generate_aggregation_id.should_not == s
      s = f.generate_aggregation_id
      f.from = F.create(:airfield)
      f.generate_aggregation_id.should be_false
      f.to = f.from
      f.generate_aggregation_id.should_not == s
    end
  end

  describe "l" do
    it "should translate FLIGHT" do
      AbstractFlight.l.should == "Abstract flight"
      AbstractFlight.l(:duration).should == "Dauer"
    end
  end

  it "should set problems_exist before saving" do
    f = Flight.spawn
    f.should_receive(:soft_validate).and_return(false)
    f.save.should be_true
    f.problems_exist?.should be_true
  end

  describe "#soft_validate" do
    it "should report a problem if there are more crew members than seats" do
      p = F.create(:plane, :seat_count => 1)
      f = Flight.create :plane => p
      f.seat2 = 2
      f.soft_validate.should be_false
      f.problems.should include :too_many_people
    end

    it "should report a problem if a trainee has a passenger" do
      p = F.create(:person) 
      p.stub(:trainee? => true)
      f = F.build(:flight, :seat1 => p, :seat2 => 1)
      f.soft_validate.should be_false
      f.problems.should include :seat2_is_not_an_instructor
    end

    it "should report a problem if the launch method does not fit the plane" do
      p = F.create(:plane, :selflaunching => false)
      f = F.build(:flight, :plane => p)
      f.soft_validate.should be_false
      f.problems.should include :launch_method_impossible
    end

    it "should report a problem if the pilot has no license" do
      plane = F.create(:plane)
      person = F.create(:person)
      f = F.build(:flight, :plane => plane, :seat1 => person)
      f.soft_validate.should be_false
      f.problems.should include :seat1_no_license
      person.licenses.create! :valid_from => 2.days.ago, :legal_plane_class_ids => [ plane.legal_plane_class_id ], :name => "fkfdj"
      f.soft_validate
      f.problems.should_not include :seat1_no_license
    end
  end
end
