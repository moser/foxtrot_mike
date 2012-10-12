def r(a)
  a[rand(a.size)]
end

def rt
  1.year.ago + rand(360).days +  (7 + rand(13)).hours + rand(60).minutes
end

planes = [ Plane.find_by_registration("D-EJSH"), Plane.find_by_registration("D-KIAM") ]
people = Person.all
af = Airfield.all

1500.times do |n|
  puts n
  Flight.create :departure => rt, :plane => r(planes), :seat1_person => r(people), :from => r(af), :to => r(af), :duration => rand(90) + 1, :controller => r(people)
end
