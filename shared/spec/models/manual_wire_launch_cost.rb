require File.expand_path(File.dirname(__FILE__) + '/../../../spec/spec_helper')

describe ManualWireLaunchCost do
  it { should belong_to :launch }
end