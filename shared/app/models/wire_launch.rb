class WireLaunch < Launch
  belongs_to :wire_launcher
  
  include WireLaunchAddition
  
  def cost
    WireLaunchCost.new(self)
  end
  
  def shared_attributes
    attributes
  end
  
  def self.short
    "W"
  end
end
