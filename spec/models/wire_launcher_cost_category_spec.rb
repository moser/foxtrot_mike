require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WireLauncherCostCategory do
  before(:each) do
    @c = WireLauncherCostCategory.generate!
    @wl = WireLauncher.generate!
    @c.wire_launcher_cost_category_memberships.create :wire_launcher => @wl, :valid_from => 2.days.ago
    @wl.reload
  end

  it "should only match a launch when the wire launcher is a member at the departure time" do
    f = Flight.generate!
    f.launch = WireLaunch.create :wire_launcher => @wl
    f.save
    @c.matches?(f).should be_true
    f.departure = 3.days.ago
    @c.matches?(f).should be_false
  end

  it "should not match a flight that is not wire launched" do
    f = Flight.generate!
    @c.matches?(f).should be_false
  end
end
