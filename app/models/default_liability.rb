class DefaultLiability
  attr_accessor :flight
  
  def initialize(flight)
    @flight = flight
  end

  def person
    flight.cost_responsible
  end

  def proportion
    1
  end

  def value
    flight.value_for(self)
  end

  def default?
    true
  end
end
