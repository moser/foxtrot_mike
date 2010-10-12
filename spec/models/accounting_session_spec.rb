require 'spec_helper'

describe AccountingSession do
  it { should have_many :accounting_entries }
  it { should validate_presence_of :name }
end
