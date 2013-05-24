require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Plane do
  it { should have_many :flights }
  it { should have_many :plane_cost_category_memberships }
  it { should have_many :financial_account_ownerships }
  it { should belong_to :group }
  it { should belong_to :legal_plane_class }

  it { should validate_presence_of :registration }
  it { should validate_presence_of :make }
  it { should validate_presence_of :group }
  it { should validate_presence_of :legal_plane_class }
  it { should validate_presence_of :default_launch_method }

  it { should allow_value("tow_launch").for(:default_launch_method) }
  it { should allow_value("wire_launch").for(:default_launch_method) }
  it { should allow_value("self_launch").for(:default_launch_method) }
  it { should_not allow_value("foo").for(:default_launch_method) }

  it "should have one current financial_account_ownership" do
    p = Plane.new
    p.should respond_to(:current_financial_account_ownership)
    m = mock("ownership")
    m.should_receive(:financial_account).at_least(:once).and_return(1)
    p.should_receive(:current_financial_account_ownership).at_least(:once).and_return(m)
    p.financial_account.should == 1
  end

  it "should return registration when sent to_s" do
    str = "D-ZZZZ"
    p = Plane.new :registration => str
    p.to_s.should == str
  end

  it "should have some flags" do
    p = Plane.new :has_engine => true, :can_tow => true, :can_fly_without_engine => false
    p.engine_duration_possible?.should be_false
  end

  it "should be sortable" do
    Plane.new.should respond_to :'<=>'
    a = Plane.new(:registration => "D-STFU")
    b = Plane.new(:registration => "D-UFTS")
    c = Plane.new(:registration => "D-0123")
    [b, c, a].sort.should == [c, a, b]
  end

  it "should find concerned accounting entry owners" do
    m = mock("make sure the block is executed")
    m.should_receive(:lala)
    wl = Plane.new
    wl.should_receive("flights").and_return([1])
    wl.find_concerned_accounting_entry_owners { |r| m.lala; r.should include(1) }
  end

  it "should set default values" do
    pl = Plane.new
    pl.default_launch_method.should == "self_launch"
    pl.seat_count.should == 1
    pl.competition_sign.should == ""
    pl.has_engine.should_not be_nil
    pl.can_tow.should_not be_nil
    pl.can_be_towed.should_not be_nil
    pl.can_be_wire_launched.should_not be_nil
    pl.selflaunching.should_not be_nil
    pl.can_fly_without_engine.should_not be_nil
  end

  it "should not throw an error if financial_account_id is called with an incorrect id" do
    pl = Plane.new
    lambda { pl.financial_account_id = -1 }.should_not raise_error
  end

  describe ".import" do
    it "creates planes from an array of hashes" do
      hashes = [
        { registration: 'D-XXXX', make: 'bar', group: 'Club', legal_plane_class: 'BAR' },
        { registration: 'MOO', make: 'cow', group: 'Club', legal_plane_class: 'FOO' }
      ]
      Plane.import(hashes)
      Plane.where(registration: 'D-XXXX').count.should == 1
      Plane.where(registration: 'MOO').count.should == 1
      LegalPlaneClass.where(name: 'BAR').count.should == 1
      LegalPlaneClass.where(name: 'FOO').count.should == 1
      Group.where(name: 'Club').count.should == 1
    end
  end
end
