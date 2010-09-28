class ManualCost < ActiveRecord::Base
  belongs_to :item, :polymorphic => true
  validates_presence_of :item, :value
  validates_numericality_of :value, :greater_than_or_equal_to => 0
end
