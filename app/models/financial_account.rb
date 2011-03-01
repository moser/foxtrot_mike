class FinancialAccount < ActiveRecord::Base
  has_many :planes
  has_many :people
  has_many :wire_launchers

  def owners
    [planes, people, wire_launchers].flatten
  end
  
  def to_s
    name
  end
end
