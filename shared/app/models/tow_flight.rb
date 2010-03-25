class TowFlight < Flight
  has_one :tow_launch
  
  #TODO add level? (own subclass?)
  
  def cost_responsible
    tow_launch.flight.cost_responsible rescue nil
  end
end
