class WireLaunch < ActiveRecord::Base
  include UuidHelper

  has_paper_trail :meta => { :abstract_flight_id => Proc.new { |l| l.abstract_flight.id unless l.nil? || l.new_record? || l.abstract_flight.nil? } }

  belongs_to :wire_launcher
  has_one :abstract_flight, :as => :launch
  has_one :manual_cost, :as => :item

  validates_presence_of :wire_launcher
  
  
  def cost
    WireLaunchCost.new(self)
  end
  
  def shared_attributes
    attributes
  end
  
  def self.short
    "W"
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
