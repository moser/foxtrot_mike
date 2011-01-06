[ PersonCostCategory, WireLauncherCostCategory, LegalPlaneClass, Group,
  FinancialAccount, Person, License, PersonCostCategoryMembership, Account, Airfield,
  Plane, WireLauncher, PlaneCostCategory, WireLauncherCostCategoryMembership,
  FlightCostRule, WireLaunchCostRule, Flight, TowFlight, WireLaunch ].reverse.map { |c| c.delete_all }

catA = PersonCostCategory.create! :name => "A"
catGlider = PlaneCostCategory.create! :name => "Glider", :tow_cost_rule_type => ""
catTowPlane = PlaneCostCategory.create! :name => "TowPlane", :tow_cost_rule_type => "TimeCostRule"
catWinch = WireLauncherCostCategory.create! :name => "Winch"

gliders = LegalPlaneClass.create! :name => "Glider"
echo = LegalPlaneClass.create! :name => "Echo"

ssv = Group.create! :name => "SSV Cham"

ppl = FinancialAccount.create :name => "ppl"
plns = FinancialAccount.create :name => "plns"
wrlnchrs = FinancialAccount.create :name => "wrlnchrs"

i = Person.create!(:firstname => "Soaring", :lastname => "Instructor", :group => ssv, :financial_account => ppl)
License.create!(:person => i, :level => "instructor", :name => "GPL", :valid_from => 1.day.ago).legal_plane_classes << gliders
PersonCostCategoryMembership.create! :valid_from => 1.year.ago, :valid_to => 1.year.from_now, 
                                     :person_cost_category => catA, :person => i

t = Person.create!(:firstname => "Soaring", :lastname => "Trainee", :group => ssv, :financial_account => ppl)
License.create!(:person => t, :level => "trainee", :name => "GPL (Schulung)", :valid_from => 1.day.ago).legal_plane_classes << gliders
PersonCostCategoryMembership.create! :valid_from => 1.year.ago, :valid_to => 1.year.from_now, 
                                     :person_cost_category => catA, :person => t

n = Person.create!(:firstname => "Normal", :lastname => "Pilot", :group => ssv, :financial_account => ppl)
License.create!(:person => n, :level => "normal", :name => "GPL", :valid_from => 1.day.ago).legal_plane_classes << gliders
License.create!(:person => n, :level => "normal", :name => "JARFCL", :valid_from => 1.day.ago).legal_plane_classes << echo
PersonCostCategoryMembership.create! :valid_from => 1.year.ago, :valid_to => 1.year.from_now, 
                                     :person_cost_category => catA, :person => n

mosr = Person.create!(:firstname => 'martin', :lastname => 'mosr', :group => ssv, :financial_account => ppl)
acc = Account.create!(:login => 'admin', :password => 'admin', :password_confirmation => 'admin', :person => mosr)
acc.account_roles.create :role => "admin"

cham = Airfield.create!(:name => "Cham")
Airfield.create!(:registration => "EDNB", :name => "Arnbruck")
Airfield.create!(:registration => "EDMS", :name => "Straubing")


sh = Plane.create!(:registration => "D-EJSH", :make => "Robin DR400", :group => ssv, :has_engine => true, :can_fly_without_engine => false, :can_tow => true,:can_be_towed => false, :can_be_wire_launched => false, :legal_plane_class => echo, :financial_account => plns)
ask13 = Plane.create!(:registration => "D-0228", :make => "ASK 13", :group => ssv, :has_engine => false, :can_fly_without_engine => true, :can_tow => false, :can_be_towed => true, :can_be_wire_launched => true, :legal_plane_class => gliders, :financial_account => plns)
fm = Plane.create!(:registration => "D-1875", :make => "Ventus 2cx", :group => ssv, :has_engine => false, :can_fly_without_engine => true, :can_tow => false, :can_be_towed => true, :can_be_wire_launched => true, :legal_plane_class => gliders, :financial_account => plns)
k8 = Plane.create!(:registration => "D-0946", :make => "Ka 8b", :group => ssv, :has_engine => false, :can_fly_without_engine => true, :can_tow => false, :can_be_towed => true, :can_be_wire_launched => true, :legal_plane_class => gliders, :financial_account => plns)
PlaneCostCategoryMembership.create! :valid_from => 1.year.ago, :valid_to => 1.year.from_now, 
                                   :plane_cost_category => catTowPlane, :plane => sh
PlaneCostCategoryMembership.create! :valid_from => 1.year.ago, :valid_to => 1.year.from_now, 
                                   :plane_cost_category => catGlider, :plane => ask13
PlaneCostCategoryMembership.create! :valid_from => 1.year.ago, :valid_to => 1.year.from_now, 
                                   :plane_cost_category => catGlider, :plane => fm
PlaneCostCategoryMembership.create! :valid_from => 1.year.ago, :valid_to => 1.year.from_now, 
                                   :plane_cost_category => catGlider, :plane => k8

winch = WireLauncher.create! :registration => "BY-123", :financial_account => wrlnchrs
WireLauncherCostCategoryMembership.create! :valid_from => 1.year.ago, :valid_to => 1.year.from_now, 
                                          :wire_launcher_cost_category => catWinch,
                                          :wire_launcher => winch
                                          
r = FlightCostRule.create! :name => "Schleppflug Mitglieder", :person_cost_category => catA, 
                    :plane_cost_category => catTowPlane, :valid_from => 1.day.ago, :flight_type => "TowFlight" 
r.flight_cost_items.create :name => "2€ pro Minute", :depends_on => 'duration', :value => 200

r = FlightCostRule.create! :name => "Segelflug normal", :person_cost_category => catA, 
                    :plane_cost_category => catGlider, :flight_type => "Flight", :valid_from => 1.day.ago 
r.flight_cost_items.create :name => "10ct pro Minute", :depends_on => 'duration', :value => 10  
 
r = WireLaunchCostRule.create! :name => "Windenstart Mitglieder", :person_cost_category => catA, 
                          :wire_launcher_cost_category => catWinch, :valid_from => 1.day.ago
r.wire_launch_cost_items.create :name => "4€", :value => 400

f = Flight.create! :seat1 => t, :seat2 => i, :plane => ask13, :departure => 1.hour.ago, :duration => 20, 
               :controller => mosr, :from => cham, :to => cham
TowFlight.create! :seat1 => n, :duration => 9, :plane => sh, :abstract_flight => f, :to => cham

f = Flight.create! :seat1 => n, :plane => fm, :departure => 2.hours.ago, :duration => 65, 
                   :controller => mosr, :from => cham, :to => cham
WireLaunch.create! :abstract_flight => f, :wire_launcher => winch
