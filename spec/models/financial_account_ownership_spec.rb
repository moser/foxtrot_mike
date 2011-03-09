require 'spec_helper'

describe FinancialAccountOwnership do
  it { should belong_to :financial_account }
  it { should belong_to :owner }
  it { should validate_presence_of :financial_account }
  it { should validate_presence_of :owner }
  
  it "should be aware of its successor if any" do
    p = Person.generate!
    f0 = FinancialAccount.generate!
    f1 = FinancialAccount.generate!
    o0 = FinancialAccountOwnership.create(:valid_from => 1.year.ago, :owner => p, :financial_account => f0)
    o1 = FinancialAccountOwnership.create(:valid_from => 10.days.ago, :owner => p, :financial_account => f1)
    #p = Person.find(p.id) #reload...
    o0.valid_to.should == 10.days.ago.to_date
    o1.valid_to.should be_nil
  end
  
  it "should know if it is valid at a given date" do
    o = FinancialAccountOwnership.new(:valid_from => 3.days.ago)
    o.should_receive(:valid_to).at_least(:once).and_return(1.day.ago)
    o.valid_at?(4.days.ago).should be_false
    o.valid_at?(2.days.ago).should be_true
    o.valid_at?(0.days.ago).should be_false
  end
  
  it "should forward getters and setters for plane, person and wire_launcher" do
    o = FinancialAccountOwnership.new
    o.should_receive(:owner).exactly(3).times.and_return(1)
    o.should_receive(:"owner=").exactly(3).times
    o.plane.should == 1
    o.person.should == 1
    o.wire_launcher.should == 1
    o.plane = 1
    o.person = 1
    o.wire_launcher = 1
  end
end
