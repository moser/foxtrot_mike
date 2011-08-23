require File.dirname(__FILE__) + '/../spec_helper'

describe DashboardsController, "show" do
  it "should authorize the user" do
    p self.class
    controller.should_receive("authorize!").with(:read, :dashboards)
    get :show
  end

  it "should get the person from the current_account and get licenses and planes" do
    controller.stub(:current_account).and_return(a = Account.generate!)
    a.person.stub(:licenses).and_return([ 1 ])
    a.person.group.stub(:planes).and_return([ 2 ])
    get :show
    assigns[:current_person].should == a.person
    assigns[:licenses].should == [ 1 ]
    assigns[:planes].should == [ 2 ]
  end
end
