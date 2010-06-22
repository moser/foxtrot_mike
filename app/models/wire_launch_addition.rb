module WireLaunchAddition
  def self.included(base) #:nodoc:
    base.acts_as_revisable :on_delete => :revise
    base.after_revise_on_destroy :set_type
  end
  
  def set_type
    p self
    self.revisable_type = self.type
    self.type = "#{self.type}Revision"
    self.revisable_original_id = self.id
    
    self.save
  end

end
