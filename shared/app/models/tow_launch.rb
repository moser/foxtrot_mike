class TowLaunch < Launch
  belongs_to :tow_flight
  
  def cost
    tow_flight.cost
  end
end
