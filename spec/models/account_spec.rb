require 'spec_helper'

describe Account do
  describe "#visible_name" do
    it "returns the persons name if there is a person" do
      account = Account.generate!
      account.person.should_receive :name
      account.visible_name
    end

    it "returns a login if there is no person" do
      account = Account.generate!(login: login = 'asdf')
      account.person = nil
      account.visible_name.should == login
    end
  end
end
