require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WireLauncherCostCategoryMembership do
  before(:each) do
    @valid_attributes = {
      :valid_from => 1.day.ago,
      :wire_launcher_cost_category => WireLauncherCostCategory.generate!,
      :wire_launcher => WireLauncher.generate!
    }
  end

  it "should create a new instance given valid attributes" do
    WireLauncherCostCategoryMembership.create!(@valid_attributes)
  end
  
  it { should belong_to :wire_launcher_cost_category }
  it { should belong_to :wire_launcher }
  
  it "should find concerned accounting entry owners" do
    m = WireLauncherCostCategoryMembership.create!(@valid_attributes)
    rel = mock("relation")
    rel.should_receive(:between).with(m.valid_from, nil)
    wl = mock("wire_launcher")
    wl.should_receive("find_concerned_accounting_entry_owners").and_yield(rel)
    m.should_receive(:wire_launcher).and_return(wl)
    m.find_concerned_accounting_entry_owners { |r| r }
  end
end
