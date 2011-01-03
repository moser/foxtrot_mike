class CostHint < ActiveRecord::Base
  has_many :cost_hint_conditions
  has_many :flights

  def to_s
    name
  end
end
