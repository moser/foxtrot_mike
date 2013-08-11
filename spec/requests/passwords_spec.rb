require "spec_helper"


describe "Passwords" do
  describe "when setting the own password" do
    # WTF test env ActiveRecord::UnknownAttributeError
    xit "should set the password" do
      visit new_password_path
      fill_in "account_password", :with => "aaaa"
      fill_in "account_password_confirmation", :with => "aaaa"
      click_button I18n.t("helpers.submit.update")
      File.open('/tmp/foo.html','w') { |f| f.puts page.body }
      page.should have_content(I18n.t("password_changed"))
      page.current_path.should == "/"
    end
  end

  describe "when setting another users password" do
    # WTF test env ActiveRecord::UnknownAttributeError
    xit "should set the password" do
      a = Account.generate!
      visit new_account_password_path(a)
      fill_in "account_password", :with => "aaaa"
      fill_in "account_password_confirmation", :with => "aaaa"
      click_button I18n.t("helpers.submit.update")
      page.should have_content(I18n.t("password_changed"))
      page.current_path.should == account_path(a)
    end

    it "should ignore additional params" do
      a = Account.generate!
      old = a.login
      t = a.updated_at
      post account_password_path(a), :account => { :password => "aaaa", :password_confirmation => "aaaa", :login => "foobar" }
      a.reload
      a.login.should == old
      a.updated_at.should_not == t
    end
  end
end
