require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Plane do
  it { should have_many :flights }
  it { should have_many :plane_cost_category_memberships }
  it { should belong_to :group }
  it { should belong_to :legal_plane_class }

  it { should validate_presence_of :group }
  it { should validate_presence_of :legal_plane_class }
  it { should have_many :financial_account_ownerships }
  it { should validate_presence_of :financial_account }
  
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
   
  it "should be revisable" do
    Plane.new.should respond_to :versions
  end
end
