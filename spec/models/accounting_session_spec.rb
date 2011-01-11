require 'spec_helper'

describe AccountingSession do
  it { should have_many :accounting_entries }
  it { should validate_presence_of :name }

  it "should not be finished unless the finished_at date is present" do
    s = AccountingSession.new
    s.finished?.should be_false
    s.finished_at = 1.hour.ago
    s.finished?.should be_true
  end
end
