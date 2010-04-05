class TowFlight < Flight
  has_one :tow_launch
  
  def cost_responsible
    tow_launch.flight.cost_responsible rescue nil
  end
  
  def departure
    tow_launch.flight.departure
  end
  
  # A tow flight ignores setting departure. It must be set on the towed flight.
  def departure=(o)
  end
end
