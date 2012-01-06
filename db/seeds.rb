#encoding: utf-8
LegalPlaneClass.create! :name => "Segelflugzeug"
LegalPlaneClass.create! :name => "Kilo (TMG)"
LegalPlaneClass.create! :name => "Kilo (SFL)"
LegalPlaneClass.create! :name => "Echo"

g = Group.create!(:name => "Heimatgruppe (Umbenennen?)")
p = Person.create!(:firstname => "Admin", :lastname => "Admin", :group => g)
Account.create!(:login => 'admin', :password => 'admin', :password_confirmation => 'admin', :person => p, :admin => true)
Airfield.create!(:name => "Heimatplatz (Umbenennen?)")
