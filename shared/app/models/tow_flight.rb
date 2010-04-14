class TowFlight < Flight
  has_one :tow_launch
  
  def cost_responsible
    tow_launch.flight.cost_responsible #rescue nil
  end
  
  def departure
    tow_launch.flight.departure #rescue nil
  end
  
  # A tow flight ignores setting departure. It must be set on the towed flight.
  def departure=(o)
  end
  
  def from
    tow_launch.flight.from #rescue nil
  end
  
  def from_id
    tow_launch.flight.from_id #rescue nil
  end
  
  def from=(o)
  end
  
  def from_id=(o)
  end
  
protected
  def after_initialize
    #puts "TowFlight#after_initialize"
    if new_record?
      self.duration = 0
    end
  end
end
