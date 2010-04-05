require File.expand_path(File.dirname(__FILE__) + '/../../../spec/spec_helper')

describe WireLauncherCostCategoryMembership do
  before(:each) do
    @valid_attributes = {
      
    }
  end

  it "should create a new instance given valid attributes" do
    WireLauncherCostCategoryMembership.create!(@valid_attributes)
  end
  
  it { should belong_to :wire_launcher_cost_category }
end
