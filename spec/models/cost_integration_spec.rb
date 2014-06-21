require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Costs" do
  it "should work :D" do
    catA = PersonCostCategory.create! :name => "A"
    catB = PersonCostCategory.create! :name => "B"
    catGlider = PlaneCostCategory.create! :name => "Glider", :tow_cost_rule_type => ""
    catTowPlane = PlaneCostCategory.create! :name => "TowPlane", :tow_cost_rule_type => "TimeCostRule"
    catWinch = WireLauncherCostCategory.create! :name => "Winch"

    @pilot_a = Person.generate! :lastname => "A", :firstname => "B"
    PersonCostCategoryMembership.create! :valid_from => 1.year.ago, :valid_to => 1.day.from_now, 
                                        :person_cost_category => catA, :person => @pilot_a
    PersonCostCategoryMembership.create! :valid_from => 1.day.from_now, :valid_to => 1.year.from_now, 
                                        :person_cost_category => catB, :person => @pilot_a

    @tow_plane = Plane.generate! :registration => "D-EEEE"
    PlaneCostCategoryMembership.create! :valid_from => 1.year.ago, :valid_to => 1.year.from_now, 
                                       :plane_cost_category => catTowPlane, :plane => @tow_plane

    @glider = Plane.generate! :registration => "D-0001"
    PlaneCostCategoryMembership.create! :valid_from => 1.year.ago, :valid_to => 1.year.from_now, 
                                       :plane_cost_category => catGlider, :plane => @glider

    @winch = WireLauncher.generate! :registration => "BY-123"
    WireLauncherCostCategoryMembership.create! :valid_from => 1.year.ago, :valid_to => 1.year.from_now, 
                                              :wire_launcher_cost_category => catWinch,
                                              :wire_launcher => @winch


    r = FlightCostRule.create :valid_from => 1.year.ago, :valid_to => 1.year.from_now,
                                :flight_type => "TowFlight", :person_cost_category => catA, 
                                :plane_cost_category => catTowPlane
    r.flight_cost_items.create :depends_on => 'duration', :value => 200


    r = FlightCostRule.create :valid_from => 1.year.ago, :valid_to => 1.year.from_now,
                                :flight_type => "Flight", :person_cost_category => catA, 
                                :plane_cost_category => catGlider
    r.flight_cost_items.create :depends_on => 'duration', :value => 10


    r = FlightCostRule.create :valid_from => 1.year.ago, :valid_to => 1.year.from_now,
                                :flight_type => "Flight", :person_cost_category => catB, 
                                :plane_cost_category => catGlider
    r.flight_cost_items.create :depends_on => 'duration', :value => 20


    r = WireLaunchCostRule.create :valid_from => 1.year.ago, :valid_to => 1.year.from_now,
                                    :person_cost_category => catA, :wire_launcher_cost_category => catWinch
    r.wire_launch_cost_items.create :value => 400


    r = WireLaunchCostRule.create :valid_from => 1.year.ago, :valid_to => 1.year.from_now,
                                    :person_cost_category => catB, :wire_launcher_cost_category => catWinch
    r.wire_launch_cost_items.create :value => 400

    [ @pilot_a, @tow_plane, @glider, @winch ].each { |o| o.reload }

  #it "should calculate costs for a winch launch and a short flight" do
    flight = Flight.create! :plane => @glider, :seat1_person => @pilot_a, :departure => Time.now, 
                             :duration => 15, :from => Airfield.generate!, :to => Airfield.generate!,
                             :controller => Person.generate!
    flight.calculate_cost_if_necessary
    flight.launch = WireLaunch.create! :wire_launcher => @winch, :abstract_flight => flight, :operator => Person.generate!
    flight.cost_responsible.should == @pilot_a
    flight.launch.abstract_flight.cost_responsible.should == @pilot_a
    flight.free_cost_sum.should == 550

    flight = Flight.create! :plane => @glider, :seat1_person => @pilot_a, :departure => 1.month.from_now, 
                             :duration => 15, :from => Airfield.generate!, :to => Airfield.generate!,
                             :controller => Person.generate!
    flight.launch = WireLaunch.create! :wire_launcher => @winch, :abstract_flight => flight, :operator => Person.generate!
    flight.calculate_cost_if_necessary
    flight.free_cost_sum.should == 700

  #it "should calculate costs for a towed flight" do
    flight = Flight.create! :plane => @glider, :seat1_person => @pilot_a, :departure => t = Time.now, 
                             :duration => 15, :from => Airfield.generate!, :to => Airfield.generate!,
                             :controller => Person.generate!
    flight.launch = TowFlight.create! :plane => @tow_plane, :seat1_person => Person.generate!, :arrival => (t + 6.minutes), 
                                       :abstract_flight => flight, :from => Airfield.generate!, :to => Airfield.generate!,
                                       :controller => Person.generate!
    flight.calculate_cost_if_necessary
    flight.launch.calculate_cost_if_necessary
    flight.launch.cost_responsible.should == @pilot_a
    flight.free_cost_sum.should == 1350
  end
end
