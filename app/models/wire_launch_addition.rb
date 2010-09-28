module WireLaunchAddition
  def self.included(base) #:nodoc:
  end

  def financial_account
    wire_launcher.financial_account
  end
  
#  def set_type
#    p self
#    self.revisable_type = self.type
#    self.type = "#{self.type}Revision"
#    self.revisable_original_id = self.id
#    
#    self.save
#  end

end
