require File.expand_path(File.dirname(__FILE__) + '/../../../spec/spec_helper')

describe ManualFlightCost do
  it { should belong_to :flight }
end
