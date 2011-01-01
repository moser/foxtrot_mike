require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ManualCost do
  it { should validate_presence_of :item }
  it { should validate_presence_of :value }
  it { should validate_numericality_of :value }
end
