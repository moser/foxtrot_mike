require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe GroupsController, "handling GET /groups.json" do

  before(:each) do
    controller.stub!(:authorized?).and_return(true)
  end

  before do
    @group = mock_model(Group, :to_json => "JSON")
    Group.stub!(:find).and_return([@group])
  end
  
  def do_get
    @request.env["HTTP_ACCEPT"] = "application/json"
    get :index
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should find all people" do
    Group.should_receive(:find).with(:all).and_return([@group])
    do_get
  end
  
  it "should assign the found people for the view" do
    do_get
    assigns[:groups].should == [@group]
  end
  
  it "should render groups as json" do
    Group.stub!(:find).and_return(stub("groups", :to_json => "JSON"))
    do_get
    response.body.should == "JSON"
  end
  
  it "should return only groups changed after x" do
    @group1 = mock_model(Group, :updated_at => 1.day.ago, :to_json => "JSON")
    Group.should_receive(:find).with(:all, :conditions => ['updated_at > ?', d = Time.at(2.days.ago.to_i).utc]).and_return([@group1])
    @request.env["HTTP_ACCEPT"] = "application/json"
    get :index, { :after => d.to_i }
    assigns[:groups].should == [@group1]
  end
end
