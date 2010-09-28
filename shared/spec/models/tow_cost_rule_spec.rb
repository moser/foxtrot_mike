require File.expand_path(File.dirname(__FILE__) + '/../../../spec/spec_helper')

describe TowCostRule do 
  it { should belong_to :plane_cost_category }
  it { should belong_to :person_cost_category }
  it { should have_many :tow_levels }
  
  it { should validate_presence_of :plane_cost_category }
  it { should validate_presence_of :person_cost_category }
end
