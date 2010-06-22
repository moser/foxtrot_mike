class WireLaunch < Launch
  belongs_to :wire_launcher
  
  include WireLaunchAddition
  
  def cost
    WireLaunchCost.new(self)
  end
end
