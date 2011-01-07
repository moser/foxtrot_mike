require 'spec_helper'

describe NumberCostRuleCondition do
  it "should only match a flight with the given condition" do
    f = Flight.spawn 
    f.duration = 30
    c = NumberCostRuleCondition.new :condition_field => "duration", :condition_operator => ">", :condition_value_i => 20
    c.matches?(f).should be_true
    f.duration = 19
    c.matches?(f).should be_false
  end

  it { should validate_presence_of :condition_field }
  it { should validate_presence_of :condition_operator }
  it { should validate_presence_of :condition_value_i }
  it { should validate_numericality_of :condition_value_i }
  it { should validate_inclusion_of :condition_field, :in => NumberCostRuleCondition.valid_fields }
  it { should validate_inclusion_of :condition_operator, :in => NumberCostRuleCondition.valid_operators }
end
