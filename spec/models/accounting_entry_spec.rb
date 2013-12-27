#encoding: UTF-8
require 'spec_helper'

describe AccountingEntry do
  it { should belong_to :from }
  it { should belong_to :to }
  it { should belong_to :accounting_session }
  it { should belong_to :item }
  it { should validate_presence_of :from }
  it { should validate_presence_of :to }
  it { should validate_presence_of :value }

  describe "#date" do
    it "should return departure date of the flight concerned" do
      a = AccountingEntry.new :item => Flight.generate!
      a.date.should == a.item.departure_date
    end

    it "should return finished_at of accounting session or created_at if no item is present" do
      a = AccountingEntry.create :accounting_session => AccountingSession.generate!(:accounting_date => 2.days.ago)
      a.date.should == 2.days.ago.to_date
    end
  end

  describe "#text" do
    it "should return the localized class name of the item if present" do
      a = AccountingEntry.new :item => Flight.generate!
      a.text.should =~ /#{Flight.l}/
    end
  end

  describe "#category_text" do
    it "returns the text if set" do
      a = AccountingEntry.new text: 'foobar'
      a.category_text.should == 'foobar'
    end

    it "returns a flight_cost_text if no text is set" do
      a = AccountingEntry.new
      a.category_text.should == 'Fluggebühren'
    end
  end
end
