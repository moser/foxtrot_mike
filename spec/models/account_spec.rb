require 'spec_helper'

describe Account do
  describe "#role" do
    it "should return a role" do
      a = Account.generate!
      a.role?(:admin).should be_false
      a.account_roles.create :role => :admin
      a = Account.find(a.id)
      a.role?(:admin).should be_true
    end
  end
end
