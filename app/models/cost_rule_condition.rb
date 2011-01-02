class CostRuleCondition < ActiveRecord::Base
  belongs_to :cost_rule, :polymorphic => true
  validates_presence_of :cost_rule
end
