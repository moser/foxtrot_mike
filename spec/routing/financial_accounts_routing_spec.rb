require "spec_helper"

describe FinancialAccountsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/financial_accounts" }.should route_to(:controller => "financial_accounts", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/financial_accounts/new" }.should route_to(:controller => "financial_accounts", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/financial_accounts/1" }.should route_to(:controller => "financial_accounts", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/financial_accounts/1/edit" }.should route_to(:controller => "financial_accounts", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/financial_accounts" }.should route_to(:controller => "financial_accounts", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/financial_accounts/1" }.should route_to(:controller => "financial_accounts", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/financial_accounts/1" }.should route_to(:controller => "financial_accounts", :action => "destroy", :id => "1")
    end

  end
end
