require 'spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/shared_examples_for_accounting_entries')

describe WireLauncher do
  it { should have_many :wire_launcher_cost_category_memberships }
  it { should have_many :wire_launches }
  it { should have_many :financial_account_ownerships }
  it { should validate_presence_of :financial_account }
  
  it "should have one current financial_account_ownership" do
    p = WireLauncher.new
    p.should respond_to(:current_financial_account_ownership)
    m = mock("ownership")
    m.should_receive(:financial_account).at_least(:once).and_return(1)
    p.should_receive(:current_financial_account_ownership).at_least(:once).and_return(m)
    p.financial_account.should == 1
  end
end
