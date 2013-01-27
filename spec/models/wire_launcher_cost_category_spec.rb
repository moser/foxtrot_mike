require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WireLauncherCostCategory do
  before(:each) do
    @c = WireLauncherCostCategory.generate!
    @wl = WireLauncher.generate!
    @c.wire_launcher_cost_category_memberships.create :wire_launcher => @wl, :valid_from => 2.days.ago
    @wl.reload
  end
  
  it { should have_many :wire_launcher_cost_category_memberships }
  it { should have_many :wire_launch_cost_rules }

  it { should validate_presence_of :name }
  
  it "should find concerned accounting entry owners" do
    o = mock("owner")
    o.should_receive(:lala)
    m = mock("membership")
    m.should_receive(:find_concerned_accounting_entry_owners).and_yield(o)
    @c.stub(:wire_launcher_cost_category_memberships).and_return([m])
    @c.find_concerned_accounting_entry_owners { |o| o.lala }
  end

  it "should only match a launch when the wire launcher is a member at the departure time" do
    f = Flight.generate!
    f.launch = WireLaunch.create :wire_launcher => @wl
    f.save
    @c.reload
    @c.matches?(f).should be_true
    f.departure = 3.days.ago
    @c.matches?(f).should be_false
  end

  it "should not match a flight that is not wire launched" do
    f = Flight.generate!
    @c.matches?(f).should be_false
  end
end
