require File.expand_path(File.dirname(__FILE__) + '/../../../spec/spec_helper')

describe TimeCostRule do 
  it { should belong_to :plane_cost_category }
  it { should belong_to :person_cost_category }
  
  it "should match a flight if there is no condition" do
    Factory.build(:time_cost_rule).matches?(Flight.new).should be_true
  end
  
  it "should match the flight's duration against a condition" do
    r = Factory.build(:time_cost_rule, :condition_field => "duration", 
                                       :condition_operator => ">=", 
                                       :condition_value => 20)
    f = Flight.new :duration => 19
    r.matches?(f).should be_false
    f.duration = 20
    r.matches?(f).should be_true
  end
  
  it "should add additive cost" do
    r = Factory.build(:time_cost_rule, :additive_cost => 100)
    f = Flight.new :duration => 1
    r.cost_for(f).should == 101
    
    r = Factory.build(:time_cost_rule, :additive_cost => -1)
    f = Flight.new :duration => 10
    r.cost_for(f).should == 9
  end
  
  it "should not produce negative cost" do
    r = Factory.build(:time_cost_rule, :additive_cost => -100)
    f = Flight.new :duration => 1
    r.cost_for(f).should == 0
  end
end
