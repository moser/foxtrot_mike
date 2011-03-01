require 'spec_helper'

describe AccountingSession do
  it { should have_many :accounting_entries }
  it { should validate_presence_of :name }
  it { should validate_presence_of :start_date }
  it { should validate_presence_of :end_date }

  it "should not be finished unless the finished_at date is present" do
    s = AccountingSession.new
    s.finished?.should be_false
    s.finished_at = 1.hour.ago
    s.finished?.should be_true
  end
  
  it "should convert end_date to a date" do
    a = AccountingSession.new(:end_date => 5.days.ago)
    a.end_date.class.should == Date
  end
  
  it "should return the maximum of to dates for latest_session_end" do
    AccountingSession.destroy_all
    AccountingSession.generate!(:end_date => 3.days.ago)
    AccountingSession.generate!(:end_date => 1.days.ago)
    AccountingSession.latest_session_end.should == 1.day.ago.to_date
  end
  
  it "should return the date before the first flight" do
    AccountingSession.destroy_all
    Flight.generate!(:departure => 2.years.ago)
    AccountingSession.latest_session_end.should == (AbstractFlight.oldest_departure.to_date - 1.day)
  end
  
  it "should have a sensible default for start_date" do
    AccountingSession.destroy_all
    d = AccountingSession.latest_session_end
    a = AccountingSession.generate!(:end_date => 5.days.ago)
    a.start_date.should == (d + 1.day)
    b = AccountingSession.generate!(:end_date => 3.days.ago)
    b.start_date.should == (a.end_date + 1.day)
  end
  
  it "should have a sensible default for end_date" do
    AccountingSession.destroy_all
    a = AccountingSession.generate!(:end_date => ((Date.today - 1.month).end_of_month))
    AccountingSession.new.end_date.should == Date.today.end_of_month
  end  
  
end
