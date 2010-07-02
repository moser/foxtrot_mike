# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead.
# Then, you can remove it from this and the functional test.
include AuthenticatedTestHelper

describe Account do
  fixtures :accounts
  
  describe 'being created' do
    before do
      @account = nil
      @creating_account = lambda do
        @account = create_account
        violated "#{@account.errors.full_messages.to_sentence}" if @account.new_record?
      end
    end

    it 'increments Account#count' do
      @creating_account.should change(Account, :count).by(1)
    end
  end

  #
  # Validations
  #

  it 'requires login' do
    lambda do
      u = create_account(:login => nil)
      u.errors[:login].should_not be_empty
    end.should_not change(Account, :count)
  end

  describe 'allows legitimate logins:' do
    ['123', '1234567890_234567890_234567890_234567890',
     'hello.-_there@funnychar.com'].each do |login_str|
      it "'#{login_str}'" do
        lambda do
          u = create_account(:login => login_str)
          u.errors[:login].should     be_empty
        end.should change(Account, :count).by(1)
      end
    end
  end
  describe 'disallows illegitimate logins:' do
    ['12', '1234567890_234567890_234567890_234567890_', "tab\t", "newline\n",
     "Iñtërnâtiônàlizætiøn hasn't happened to ruby 1.8 yet",
     'semicolon;', 'quote"', 'tick\'', 'backtick`', 'percent%', 'plus+', 'space '].each do |login_str|
      it "'#{login_str}'" do
        lambda do
          u = create_account(:login => login_str)
          u.errors[:login].should_not be_empty
        end.should_not change(Account, :count)
      end
    end
  end

  it 'requires password' do
    lambda do
      u = create_account(:password => nil)
      u.errors[:password].should_not be_empty
    end.should_not change(Account, :count)
  end

  it 'requires password confirmation' do
    lambda do
      u = create_account(:password_confirmation => nil)
      u.errors[:password_confirmation].should_not be_empty
    end.should_not change(Account, :count)
  end

  it 'resets password' do
    accounts(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    Account.authenticate('quentin', 'new password').should == accounts(:quentin)
  end

  it 'does not rehash password' do
    accounts(:quentin).update_attributes(:login => 'quentin2')
    Account.authenticate('quentin2', 'monkey').should == accounts(:quentin)
  end

  #
  # Authentication
  #

  it 'authenticates account' do
    Account.authenticate('quentin', 'monkey').should == accounts(:quentin)
  end

  it "doesn't authenticate account with bad password" do
    Account.authenticate('quentin', 'invalid_password').should be_nil
  end

 if REST_AUTH_SITE_KEY.blank?
   # old-school passwords
   it "authenticates a user against a hard-coded old-style password" do
     Account.authenticate('old_password_holder', 'test').should == accounts(:old_password_holder)
   end
 else
   it "doesn't authenticate a user against a hard-coded old-style password" do
     Account.authenticate('old_password_holder', 'test').should be_nil
   end

   # New installs should bump this up and set REST_AUTH_DIGEST_STRETCHES to give a 10ms encrypt time or so
   desired_encryption_expensiveness_ms = 0.1
   it "takes longer than #{desired_encryption_expensiveness_ms}ms to encrypt a password" do
     test_reps = 100
     start_time = Time.now; test_reps.times{ Account.authenticate('quentin', 'monkey'+rand.to_s) }; end_time   = Time.now
     auth_time_ms = 1000 * (end_time - start_time)/test_reps
     auth_time_ms.should > desired_encryption_expensiveness_ms
   end
 end

  #
  # Authentication
  #

  it 'sets remember token' do
    accounts(:quentin).remember_me
    accounts(:quentin).remember_token.should_not be_nil
    accounts(:quentin).remember_token_expires_at.should_not be_nil
  end

  it 'unsets remember token' do
    accounts(:quentin).remember_me
    accounts(:quentin).remember_token.should_not be_nil
    accounts(:quentin).forget_me
    accounts(:quentin).remember_token.should be_nil
  end

  it 'remembers me for one week' do
    before = 1.week.from_now.utc
    accounts(:quentin).remember_me_for 1.week
    after = 1.week.from_now.utc
    accounts(:quentin).remember_token.should_not be_nil
    accounts(:quentin).remember_token_expires_at.should_not be_nil
    accounts(:quentin).remember_token_expires_at.between?(before, after).should be_true
  end

  it 'remembers me until one week' do
    time = 1.week.from_now.utc
    accounts(:quentin).remember_me_until time
    accounts(:quentin).remember_token.should_not be_nil
    accounts(:quentin).remember_token_expires_at.should_not be_nil
    accounts(:quentin).remember_token_expires_at.should == time
  end

  it 'remembers me default two weeks' do
    before = 2.weeks.from_now.utc
    accounts(:quentin).remember_me
    after = 2.weeks.from_now.utc
    accounts(:quentin).remember_token.should_not be_nil
    accounts(:quentin).remember_token_expires_at.should_not be_nil
    accounts(:quentin).remember_token_expires_at.between?(before, after).should be_true
  end

protected
  def create_account(options = {})
    record = Account.new({ :login => 'quire', :email => 'quire@example.com', :password => 'quire69', :password_confirmation => 'quire69' }.merge(options))
    record.save
    record
  end
end
