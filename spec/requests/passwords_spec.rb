require "spec_helper"

def generate_account
  a = Account.spawn
  a.save_without_session_maintenance
  a
end

describe "Passwords" do
  context "when setting the own password" do
    xit "should " do
      
    end
  end

  context "when setting another users password" do
    it "should set the password" do
      a = generate_account
      visit new_account_password_path(a)
      fill_in "account_password", :with => "aaaa"
      fill_in "account_password_confirmation", :with => "aaaa"
      click_button "Ok"
      page.should have_content(I18n.t("password_changed"))
      page.current_path.should == account_path(a)
    end

    it "should ignore additional params" do
      a = generate_account
      old = a.login
      t = a.updated_at
      post account_password_path(a), :account => { :password => "aaaa", :password_confirmation => "aaaa", :login => "foobar" }
      a.reload
      a.login.should == old
      a.updated_at.should_not == t
    end
  end
end
