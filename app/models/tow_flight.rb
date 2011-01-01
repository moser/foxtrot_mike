class TowFlight < AbstractFlight
  before_validation :set_departure
  has_one :abstract_flight, :as => :launch #the towed flight
  
  def cost_responsible
    abstract_flight.cost_responsible #rescue nil
  end

  def financial_account
    plane.financial_account
  end
  
#  def from
#    abstract_flight.from rescue nil
#  end
#  
#  def from_id
#    abstract_flight.from_id rescue nil
#  end

  def purpose
    @purpose ||= Purpose.new('tow')
  end
  
  def initialize(*args)
    super(*args)
    if new_record?
      self.duration ||= 0
    end
  end

private
  def set_departure
    unless abstract_flight.nil?
      self.departure = abstract_flight.departure
      self.from = abstract_flight.from
      self.controller = abstract_flight.controller
    end
  end
end
