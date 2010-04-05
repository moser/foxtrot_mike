require File.expand_path(File.dirname(__FILE__) + '/../../../spec/spec_helper')

describe TowCostRule do 
  it { should belong_to :plane_cost_category }
  it { should belong_to :person_cost_category }
  it { should have_many :tow_levels }
  
end
