require File.expand_path(File.dirname(__FILE__) + '/../../../spec/spec_helper')

describe "Costs" do
  before :all do
    catA = PersonCostCategory.create :name => "A"
    catB = PersonCostCategory.create :name => "B"
    catGlider = PlaneCostCategory.create :name => "Glider", :tow_cost_rule_type => ""
    catTowPlane = PlaneCostCategory.create :name => "TowPlane", :tow_cost_rule_type => "TimeCostRule"
    catWinch = WireLauncherCostCategory.create :name => "Winch"
    
    @pilot_a = Person.create :lastname => "A"
    PersonCostCategoryMembership.create :valid_from => 1.year.ago, :valid_to => 1.day.from_now, 
                                        :person_cost_category => catA, :person => @pilot_a
    PersonCostCategoryMembership.create :valid_from => 1.day.from_now, :valid_to => 1.year.from_now, 
                                        :person_cost_category => catB, :person => @pilot_a
    
    @tow_plane = Plane.create :registration => "D-EEEE"
    PlaneCostCategoryMembership.create :valid_from => 1.year.ago, :valid_to => 1.year.from_now, 
                                       :plane_cost_category => catTowPlane, :plane => @tow_plane
                                       
    @glider = Plane.create :registration => "D-0001"
    PlaneCostCategoryMembership.create :valid_from => 1.year.ago, :valid_to => 1.year.from_now, 
                                       :plane_cost_category => catGlider, :plane => @glider
                                       
    @winch = WireLauncher.create :registration => "BY-123"
    WireLauncherCostCategoryMembership.create :valid_from => 1.year.ago, :valid_to => 1.year.from_now, 
                                              :wire_launcher_cost_category => catWinch,
                                              :wire_launcher => @winch
    
    TimeCostRule.create :valid_from => 2.years.ago, :valid_to => 1.year.ago,
                        :name => "1€ per minute (tow, outdated)", :person_cost_category => catA, 
                        :plane_cost_category => catTowPlane, :depends_on => 'duration',
                        :cost => 100, :flight_type => "TowFlight"
    TimeCostRule.create :valid_from => 1.year.ago, :valid_to => 1.year.from_now,
                        :name => "2€ per minute (tow)", :person_cost_category => catA, 
                        :plane_cost_category => catTowPlane, :depends_on => 'duration',
                        :cost => 200, :flight_type => "TowFlight"
    
    TimeCostRule.create :valid_from => 2.years.ago, :valid_to => 1.year.ago,
                        :name => "1ct per minute (outdated)", :person_cost_category => catA, 
                        :plane_cost_category => catGlider, :depends_on => 'duration',
                        :cost => 1, :flight_type => "Flight"
    TimeCostRule.create :valid_from => 1.year.ago, :valid_to => 1.year.from_now,
                        :name => "10ct per minute", :person_cost_category => catA, 
                        :plane_cost_category => catGlider, :depends_on => 'duration',
                        :cost => 10, :flight_type => "Flight"
    TimeCostRule.create :valid_from => 1.year.ago, :valid_to => 1.year.from_now,
                        :name => "20ct per minute", :person_cost_category => catB, 
                        :plane_cost_category => catGlider, :depends_on => 'duration',
                        :cost => 20, :flight_type => "Flight"

    WireLaunchCostRule.create :valid_from => 2.years.ago, :valid_to => 1.year.ago,
                              :name => "1€ for a winch launch (outdated)", 
                              :person_cost_category => catA, 
                              :wire_launcher_cost_category => catWinch, :cost => 100
    WireLaunchCostRule.create :valid_from => 1.year.ago, :valid_to => 1.year.from_now,
                              :name => "4€ for a winch launch", :person_cost_category => catA, 
                              :wire_launcher_cost_category => catWinch, :cost => 400

    WireLaunchCostRule.create :valid_from => 1.year.ago, :valid_to => 1.year.from_now,
                              :name => "4€ for a winch launch", :person_cost_category => catB, 
                              :wire_launcher_cost_category => catWinch, :cost => 400
  end
  
  it "should calculate costs for a winch launch and a short flight" do
    flight = Flight.create :plane => @glider, :seat1 => @pilot_a, :departure => Time.now, 
                           :duration => 15
    flight.launch = WireLaunch.create :wire_launcher => @winch
    flight.cost_responsible.should == @pilot_a
    flight.cost.to_i.should == 550
    
    flight = Flight.create :plane => @glider, :seat1 => @pilot_a, :departure => 1.month.from_now, 
                           :duration => 15
    flight.launch = WireLaunch.create :wire_launcher => @winch
    flight.cost.to_i.should == 700
  end
  
  it "should calculate costs for a towed flight" do
    flight = Flight.create :plane => @glider, :seat1 => @pilot_a, :departure => Time.now, 
                           :duration => 15
    tow_flight = TowFlight.create :plane => @tow_plane, :departure => flight.departure, 
                                  :duration => 6
    flight.launch = TowLaunch.create :tow_flight => tow_flight
    tow_flight.cost_responsible.should == @pilot_a
    flight.cost.to_i.should == 1350
  end
end
