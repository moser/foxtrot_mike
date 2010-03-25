require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Costs" do
  before :all do
    catA = PersonCostCategory.create :name => "A"
    catGlider = PlaneCostCategory.create :name => "Glider"
    catTowPlane = PlaneCostCategory.create :name => "TowPlane"
    catWinch = WireLauncherCostCategory.create :name => "Winch"
    
    @pilot_a = Person.create :lastname => "A"
    m = PersonCostCategoryMembership.create :from => 1.year.ago, :to => 1.year.from_now, 
                                            :person_cost_category => catA
    @pilot_a.person_cost_category_memberships << m 
    
    @tow_plane = Plane.create :registration => "D-EEEE", :plane_cost_category => catTowPlane
    @glider = Plane.create :registration => "D-0001", :plane_cost_category => catGlider
    @winch = WireLauncher.create :registration => "BY-123", :wire_launcher_cost_category => catWinch
    
    TimeCostRule.create :name => "2€ pre minute (tow)", :person_cost_category => catA, 
                        :plane_cost_category => catTowPlane, :depends_on => 'duration',
                        :cost => 200, :flight_type => "TowFlight"
    
    TimeCostRule.create :name => "10ct pre minute", :person_cost_category => catA, 
                        :plane_cost_category => catGlider, :depends_on => 'duration',
                        :cost => 10, :flight_type => "Flight"
                        
    WireLaunchCostRule.create :name => "4€ for a winch launch", :person_cost_category => catA, 
                              :wire_launcher_cost_category => catWinch, :cost => 400
    
    
    
  end
  
  it "should calculate costs for a winch launch and a short flight" do
    flight = Flight.create :plane => @glider, :seat1 => @pilot_a, :departure => Time.now, 
                           :duration => 15
    flight.launch = WireLaunch.create :wire_launcher => @winch
    flight.save
    flight.cost_responsible.should == @pilot_a
    flight.cost.should == 550
  end
  
  it "should calculate costs for a towed flight" do
    flight = Flight.create :plane => @glider, :seat1 => @pilot_a, :departure => Time.now, 
                           :duration => 15
    tow_flight = TowFlight.create :plane => @tow_plane, :departure => flight.departure, 
                                  :duration => 6
    flight.launch = TowLaunch.create :tow_flight => tow_flight
    flight.save
    tow_flight.cost_responsible.should == @pilot_a
    flight.cost.should == 1350
  end
end
