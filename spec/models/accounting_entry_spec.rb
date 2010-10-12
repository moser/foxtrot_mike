require 'spec_helper'

describe AccountingEntry do
  it { should belong_to :from }
  it { should belong_to :to }
  it { should belong_to :accounting_session }
  it { should validate_presence_of :from }
  it { should validate_presence_of :to }
  it { should validate_presence_of :value }
end
