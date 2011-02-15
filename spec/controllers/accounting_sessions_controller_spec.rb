require 'spec_helper'

describe AccountingSessionsController, :index do
  it "should check if the current user may read accounting sessions" do
    controller.should_receive("authorize!").with(:read, AccountingSession)
    get :index
  end
end

describe AccountingSessionsController, :new do
  it "should check if the current user may create a new accounting session" do
    controller.should_receive("authorize!").with(:create, kind_of(AccountingSession))
    get :new
  end
end
