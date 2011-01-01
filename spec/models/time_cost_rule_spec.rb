require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TimeCostRule do 
  before(:all) { TimeCostRule.generate! } #make sure there is already a record (for should validate_uniqueness_of)

  it { should belong_to :plane_cost_category }
  it { should belong_to :person_cost_category }

  it { should validate_inclusion_of :flight_type, :in => ["TowFlight", "Flight"] }
  it { should validate_uniqueness_of :name }
  it { should validate_presence_of :cost }
  it { should validate_presence_of :flight_type }
  it { should validate_presence_of :name }

  it { should validate_presence_of :plane_cost_category }
  it { should validate_presence_of :person_cost_category }

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
