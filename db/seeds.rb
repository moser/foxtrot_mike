catA = PersonCostCategory.create :name => "A"
catGlider = PlaneCostCategory.create :name => "Glider", :tow_cost_rule_type => ""
catTowPlane = PlaneCostCategory.create :name => "TowPlane", :tow_cost_rule_type => "TimeCostRule"
catWinch = WireLauncherCostCategory.create :name => "Winch"

ssv = Group.create :name => "SSV Cham"

Person.create(:firstname => "Soaring", :lastname => "Instructor", :group => ssv) #TODO add instructor license
Person.create(:firstname => "Soaring", :lastname => "Trainee", :group => ssv) #TODO add trainee license
n = Person.create(:firstname => "Normal", :lastname => "Pilot", :group => ssv) #TODO add license
m = PersonCostCategoryMembership.create :valid_from => 1.year.ago, :valid_to => 1.year.from_now, 
                                        :person_cost_category => catA
n.person_cost_category_memberships << m 

mosr = Person.create(:firstname => 'martin', :lastname => 'mosr', :group => ssv)
acc = Account.create(:login => 'moser', :password => 'lalala', :password_confirmation => 'lalala', :person => mosr)

Airfield.create(:name => "Cham")
Airfield.create(:registration => "EDNB", :name => "Arnbruck")
Airfield.create(:registration => "EDMS", :name => "Straubing")


sh = Plane.create(:registration => "D-EJSH", :make => "Robin DR400", :group => ssv, :has_engine => true, :can_fly_without_engine => false, :can_tow => true,:can_be_towed => false, :can_be_wire_launched => false)
ask13 = Plane.create(:registration => "D-0228", :make => "ASK 13", :group => ssv, :has_engine => false, :can_fly_without_engine => true, :can_tow => false, :can_be_towed => true, :can_be_wire_launched => true)
fm = Plane.create(:registration => "D-1875", :make => "Ventus 2cx", :group => ssv, :has_engine => false, :can_fly_without_engine => true, :can_tow => false, :can_be_towed => true, :can_be_wire_launched => true)
k8 = Plane.create(:registration => "D-0946", :make => "Ka 8b", :group => ssv, :has_engine => false, :can_fly_without_engine => true, :can_tow => false, :can_be_towed => true, :can_be_wire_launched => true)
PlaneCostCategoryMembership.create :valid_from => 1.year.ago, :valid_to => 1.year.from_now, 
                                   :plane_cost_category => catTowPlane, :plane => sh
PlaneCostCategoryMembership.create :valid_from => 1.year.ago, :valid_to => 1.year.from_now, 
                                   :plane_cost_category => catGlider, :plane => ask13
PlaneCostCategoryMembership.create :valid_from => 1.year.ago, :valid_to => 1.year.from_now, 
                                   :plane_cost_category => catGlider, :plane => fm
PlaneCostCategoryMembership.create :valid_from => 1.year.ago, :valid_to => 1.year.from_now, 
                                   :plane_cost_category => catGlider, :plane => k8

winch = WireLauncher.create :registration => "BY-123"
WireLauncherCostCategoryMembership.create :valid_from => 1.year.ago, :valid_to => 1.year.from_now, 
                                          :wire_launcher_cost_category => catWinch,
                                          :wire_launcher => winch
                                          
TimeCostRule.create :name => "2€ pre minute (tow)", :person_cost_category => catA, 
                    :plane_cost_category => catTowPlane, :depends_on => 'duration',
                    :cost => 200, :flight_type => "TowFlight"
TimeCostRule.create :name => "10ct pre minute", :person_cost_category => catA, 
                    :plane_cost_category => catGlider, :depends_on => 'duration',
                    :cost => 10, :flight_type => "Flight"          
WireLaunchCostRule.create :name => "4€ for a winch launch", :person_cost_category => catA, 
                          :wire_launcher_cost_category => catWinch, :cost => 400
                          

