require File.expand_path(File.dirname(__FILE__) + '/../../../spec/spec_helper')

describe TowLevel do
  it { should belong_to :tow_cost_rule }
end
