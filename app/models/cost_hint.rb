class CostHint < ActiveRecord::Base
  has_many :cost_hint_conditions
  has_many :flights
  validates_presence_of :name

  default_scope order("name ASC")

  def to_s
    name
  end

  def to_j
    { :id => id, :name => name }
  end
end
