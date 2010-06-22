require File.expand_path(File.dirname(__FILE__) + '/../../../spec/spec_helper')

describe Launch do  
  it { should belong_to :abstract_flight }
end
