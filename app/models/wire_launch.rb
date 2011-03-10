class WireLaunch < ActiveRecord::Base
  include UuidHelper

  has_paper_trail :meta => { :abstract_flight_id => Proc.new { |l| l.abstract_flight.id unless l.nil? || l.new_record? || l.abstract_flight.nil? } }

  has_many :accounting_entries, :as => :item
  belongs_to :wire_launcher
  has_one :abstract_flight, :as => :launch
  has_one :manual_cost, :as => :item
  
  class << self
    def between(from, to)
      joins(:abstract_flight).where("abstract_flights.departure >= ? AND abstract_flights.departure < ?", from, to)
    end
    
    def after(from)
      joins(:abstract_flight).where("abstract_flights.departure >= ?", from)
    end
    
    def before(to)
      joins(:abstract_flight).where("abstract_flights.departure < ?", to)
    end
  end

  validates_presence_of :wire_launcher
  
  include LaunchAccountingEntries
  
  def cost
    unless @cost
      candidates = WireLaunchCostRule.for(self.abstract_flight).map { |cr| cr.apply_to(self) }
      candidates = candidates.sort_by { |a| a.free_sum }
      @cost = candidates.first
    end
    @cost
  end

  def free_cost_sum
    cost.free_sum
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
