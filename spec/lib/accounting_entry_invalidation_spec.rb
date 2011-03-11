require File.dirname(__FILE__) + '/../spec_helper'

class Foo
  include AccountingEntryInvalidation
end

describe AccountingEntryInvalidation do
  before(:all) { @f = Foo.new }
  
  it "should call invalidate_accounting_entries on every concerned owner" do
    m = mock("owner")
    m.should_receive(:invalidate_accounting_entries).with(false)
    @f.should_receive(:find_concerned_accounting_entry_owners).with(:a, 1, 2).and_return([m])
    @f.invalidate_concerned_accounting_entries(:a, 1, 2)
  end
  
  describe "max_date" do
    it "should return the maximum of two dates" do
      a, b = 1.day.ago, 10.days.ago
      @f.max_date(a, b).should == a
      @f.max_date(b, a).should == a
    end
    
    it "should return nil if any of both dates is nil" do
      a = 1.day.ago
      @f.max_date(a, nil).should be_nil
      @f.max_date(nil, a).should be_nil
    end
  end
  
  describe "min_date" do
    it "should return the minimum of two dates" do
      a, b = 1.day.ago, 10.days.ago
      @f.min_date(a, b).should == b
      @f.min_date(b, a).should == b
    end
    
    it "should return nil if any of both dates is nil" do
      a = 1.day.ago
      @f.min_date(a, nil).should be_nil
      @f.min_date(nil, a).should be_nil
    end
  end
end
