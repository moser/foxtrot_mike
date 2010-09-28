module TowLaunchAddition
  def self.included(base) #:nodoc:
  end

  def financial_account
    tow_flight.plane.financial_account
  end
end
