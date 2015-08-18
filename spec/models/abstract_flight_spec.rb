require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AbstractFlight do
  it { should belong_to :plane }
  it { should belong_to :seat1_person }
  it { should belong_to :seat2_person }
  it { should belong_to :from }
  it { should belong_to :to }
  
  it { should have_many :accounting_entries }
  it { should belong_to :launch }

  it { should validate_presence_of :plane }
  it { should validate_presence_of :seat1_person }
  it { should validate_presence_of :from }
  it { should validate_presence_of :to }
  
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
  
  describe "crew members" do
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

    describe "seat1_role" do
      it "returns :unknown if there is no person set" do
        @f.seat1_person = nil
        @f.seat1_role.should == :unknown
      end

      it "returns :pic if the person on seat1 has a license" do
        @f.seat1_person = @pilot
        @f.seat1_role.should == :pic
      end

      it "returns :trainee it the person on seat1 has no license" do
        @f.seat1_person = @trainee
        @f.seat1_role.should == :trainee
      end
    end
  
    describe "seat2_role" do
      it "returns :empty if there is no person set and seat2_n is 0" do
        @f.seat2_role.should == :empty
      end

      it "returns instructor if seat1 is not a trainee and seat2 an instructor" do
        @f.seat1_person = @trainee
        @f.seat2_person = @instructor
        @f.seat2_role.should == :instructor
      end

      it "returns passenger if seat1 is not a trainee and seat2 not an instructor" do
        @f.seat1_person = @pilot
        @f.seat2_person = @trainee
        @f.seat2_role.should == :passenger
      end

      it "returns :multiple_passengers if seat2_n is >0" do
        @f.seat2_n = 2
        @f.seat2_role.should == :multiple_passengers
      end
    end
  end
  
  describe "launch_attributes" do
    
  end
  
  describe "cost" do
    it "should be nil if there is no crew" do
      f = Flight.new
      f.cost.should be_empty
    end
  end
  
  describe "aggregation_id" do
    it "should change when plane, departure_date or seat1 change" do
      f = F.build(:flight)
      f.from = f.to
      s = f.generate_aggregation_id
      f.plane = F.create(:plane)
      f.generate_aggregation_id.should_not == s
      f.departure_date = 1.day.ago
      f.generate_aggregation_id.should_not == s
      s = f.generate_aggregation_id
      f.seat1_person = F.create(:person)
      f.generate_aggregation_id.should_not == s
      s = f.generate_aggregation_id
      f.seat1_person = F.create(:person)
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

  describe "#too_many_people_for_plane?" do
    it "indicates that there too many people on the plane" do
      p = F.create(:plane, :seat_count => 1)
      f = Flight.create :plane => p
      f.too_many_people_for_plane?.should be_false
      f.seat2_n = 2
      f.too_many_people_for_plane?.should be_true
    end
  end

  describe "#seat2_is_not_an_instructor" do
    it "indicates that an trainee has a passenger" do
      p = F.create(:person) 
      p.stub(:trainee? => true)
      f = F.build(:flight, :seat1_person => p)
      f.seat2_not_an_instructor?.should be_false
      f.seat2_n = 2
      f.seat2_not_an_instructor?.should be_true
    end
  end

  describe "#launch_method_impossible?" do
    it "returns true if the launch method does not fit the plane" do
      p = F.create(:plane, :selflaunching => false)
      f = F.build(:flight, :plane => p)
      f.launch_method_impossible?.should be_true
    end
  end

  describe "#seat1_no_license?" do
    it "indicates that the person on seat1 has no proper license" do
      plane = F.create(:plane)
      person = F.create(:person)
      f = F.build(:flight, :plane => plane, :seat1_person => person)
      f.seat1_no_license?.should be_true
      person.licenses.create! :valid_from => 2.days.ago, :legal_plane_class_ids => [ plane.legal_plane_class_id ], :name => "fkfdj"
      f.seat1_no_license?.should be_false
    end
  end

  describe "#concerned_people" do
    it "returns all the people which are somehow concerned by this flight" do
      f = F.create(:flight, seat2_person: F.create(:person))
      f.concerned_people.should be_include(f.seat1_person)
      f.concerned_people.should be_include(f.seat2_person)
      f.concerned_people.should be_include(f.controller)
    end
  end
end
