class WireLaunch < Launch
  belongs_to :wire_launcher
  
  def cost
    WireLaunchCost.new(self)
  end
end
