Person.create(:firstname => "Soaring", :lastname => "Instructor") #TODO add instructor license
Person.create(:firstname => "Soaring", :lastname => "Trainee") #TODO add trainee license
Person.create(:firstname => "Normal", :lastname => "Pilot") #TODO add license

mosr = Person.create(:firstname => 'martin', :lastname => 'mosr')
acc = Account.create(:login => 'moser', :password => 'lalala', :password_confirmation => 'lalala', :person => mosr)

Airfield.create(:name => "Cham")
Airfield.create(:registration => "EDNB", :name => "Arnbruck")
Airfield.create(:registration => "EDMS", :name => "Straubing")

Plane.create(:registration => "D-EJSH", :make => "Robin DR400")
Plane.create(:registration => "D-0228", :make => "ASK 13")
Plane.create(:registration => "D-1875", :make => "Ventus 2cx")
Plane.create(:registration => "D-0946", :make => "Ka 8b")
