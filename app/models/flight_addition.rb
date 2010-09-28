module FlightAddition  
  def self.included(base) #:nodoc:
  end

  def bookings
    launch_account = launch.financial_account
    plane_account = plane.financial_account
    #launch_cost = launch.cost.value
    flight_cost = cost
    b = liabilities_with_default.map do |l|
      [ { :from => l.person.financial_account, :to => launch_account, :value => (proportion_for(l) * flight_cost.launch_cost.value).round },
        { :from => l.person.financial_account, :to => plane_account, :value =>  (proportion_for(l) * flight_cost.value).round } ]
    end
    b.flatten
  end
end
