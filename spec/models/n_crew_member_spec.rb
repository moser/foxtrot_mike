require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NCrewMember do  
  it { should ensure_immutability_of(:n, 1) }
  
  it "should respond to to_s" do
    NCrewMember.new(:n => 1).to_s.should == "+1"
  end

  it "value should return n" do
    m = NCrewMember.new :n => 1
    m.value.should == 1    
  end
end
