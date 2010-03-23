require File.dirname(__FILE__) + '/../spec_helper'

describe AirfieldsController, "#route_for" do

  it "should map { :controller => 'airfields', :action => 'index' } to /airfields" do
    route_for(:controller => "airfields", :action => "index").should == "/airfields"
  end
  
  it "should map { :controller => 'airfields', :action => 'new' } to /airfields/new" do
    route_for(:controller => "airfields", :action => "new").should == "/airfields/new"
  end
  
  it "should map { :controller => 'airfields', :action => 'show', :id => 1 } to /airfields/1" do
    route_for(:controller => "airfields", :action => "show", :id => '1').should == "/airfields/1"
  end
  
  it "should map { :controller => 'airfields', :action => 'edit', :id => 1 } to /airfields/1/edit" do
    route_for(:controller => "airfields", :action => "edit", :id => '1').should == "/airfields/1/edit"
  end
  
  it "should map { :controller => 'airfields', :action => 'update', :id => 1} to /airfields/1" do
    route_for(:controller => "airfields", :action => "update", :id => '1').should == { :path => "/airfields/1", :method => :put }
  end
  
  it "should map { :controller => 'airfields', :action => 'destroy', :id => 1} to /airfields/1" do
    route_for(:controller => "airfields", :action => "destroy", :id => '1').should == { :path => "/airfields/1", :method => :delete }
  end
  
end

describe AirfieldsController, "handling GET /airfields" do

  before(:each) do
    controller.stub!(:authorized?).and_return(true)
  end

  before do
    @airfield = mock_model(Airfield)
    Airfield.stub!(:find).and_return([@airfield])
  end
  
  def do_get
    get :index
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end

  it "should render index template" do
    do_get
    response.should render_template('index')
  end
  
  it "should find all airfields" do
    Airfield.should_receive(:find).with(:all).and_return([@airfield])
    do_get
  end
  
  it "should assign the found airfields for the view" do
    do_get
    assigns[:airfields].should == [@airfield]
  end
end

describe AirfieldsController, "handling GET /airfields.json" do

  before(:each) do
    controller.stub!(:authorized?).and_return(true)
  end

  before do
    @airfield = mock_model(Airfield, :to_json => "JSON")
    Airfield.stub!(:find).and_return(@airfield)
  end
  
  def do_get
    @request.env["HTTP_ACCEPT"] = "application/json"
    get :index
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end

  it "should find all airfields" do
    Airfield.should_receive(:find).with(:all).and_return([@airfield])
    do_get
  end
  
  it "should render the found airfield as json" do
    @airfield.should_receive(:to_json).and_return("JSON")
    do_get
    response.body.should == "JSON"
  end
end

describe AirfieldsController, "handling GET /airfields/1" do#

  before(:each) do
    controller.stub!(:authorized?).and_return(true)
  end

  before do
    @airfield = mock_model(Airfield)
    Airfield.stub!(:find).and_return(@airfield)
  end
  
  def do_get
    get :show, :id => "1"
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should render show template" do
    do_get
    response.should render_template('show')
  end
  
  it "should find the airfield requested" do
    Airfield.should_receive(:find).with("1").and_return(@airfield)
    do_get
  end
  
  it "should assign the found airfield for the view" do
    do_get
    assigns[:airfield].should equal(@airfield)
  end
end

describe AirfieldsController, "handling GET /airfields/1.json" do

  before(:each) do
    controller.stub!(:authorized?).and_return(true)
  end

  before do
    @airfield = mock_model(Airfield, :to_json => "JSON")
    Airfield.stub!(:find).and_return(@airfield)
  end
  
  def do_get
    @request.env["HTTP_ACCEPT"] = "application/json"
    get :show, :id => "1"
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should find the airfield requested" do
    Airfield.should_receive(:find).with("1").and_return(@airfield)
    do_get
  end
  
  it "should render the found airfield as json" do
    @airfield.should_receive(:to_json).and_return("JSON")
    do_get
    response.body.should == "JSON"
  end
end

describe AirfieldsController, "handling GET /airfields/new" do

  before(:each) do
    controller.stub!(:authorized?).and_return(true)
  end

  before do
    @airfield = mock_model(Airfield)
    Airfield.stub!(:new).and_return(@airfield)
  end
  
  def do_get
    get :new
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should render new template" do
    do_get
    response.should render_template('new')
  end
  
  it "should create an new airfield" do
    Airfield.should_receive(:new).and_return(@airfield)
    do_get
  end
  
  it "should not save the new airfield" do
    @airfield.should_not_receive(:save)
    do_get
  end
  
  it "should assign the new airfield for the view" do
    do_get
    assigns[:airfield].should equal(@airfield)
  end
end

describe AirfieldsController, "handling GET /airfields/1/edit" do

  before(:each) do
    controller.stub!(:authorized?).and_return(true)
  end

  before do
    @airfield = mock_model(Airfield)
    Airfield.stub!(:find).and_return(@airfield)
  end
  
  def do_get
    get :edit, :id => "1"
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should render edit template" do
    do_get
    response.should render_template('edit')
  end
  
  it "should find the airfield requested" do
    Airfield.should_receive(:find).and_return(@airfield)
    do_get
  end
  
  it "should assign the found airfield for the view" do
    do_get
    assigns[:airfield].should equal(@airfield)
  end
end

describe AirfieldsController, "handling POST /airfields" do

  before(:each) do
    controller.stub!(:authorized?).and_return(true)
  end

  before do
    @airfield = mock_model(Airfield, :to_param => "1")
    Airfield.stub!(:new).and_return(@airfield)
  end
  
  def post_with_successful_save
    @airfield.should_receive(:save).and_return(true)
    post :create, :airfield => {}
  end
  
  def post_with_failed_save
    @airfield.should_receive(:save).and_return(false)
    post :create, :airfield => {}
  end
  
  it "should create a new airfield" do
    Airfield.should_receive(:new).with({}).and_return(@airfield)
    post_with_successful_save
  end

  it "should redirect to the new airfield on successful save" do
    post_with_successful_save
    response.should redirect_to(airfield_url("1"))
  end

  it "should re-render 'new' on failed save" do
    post_with_failed_save
    response.should render_template('new')
  end
end

describe AirfieldsController, "handling PUT /airfields/1" do

  before(:each) do
    controller.stub!(:authorized?).and_return(true)
  end

  before do
    @airfield = mock_model(Airfield, :to_param => "1")
    Airfield.stub!(:find).and_return(@airfield)
  end
  
  def put_with_successful_update
    @airfield.should_receive(:update_attributes).and_return(true)
    put :update, :id => "1"
  end
  
  def put_with_failed_update
    @airfield.should_receive(:update_attributes).and_return(false)
    put :update, :id => "1"
  end
  
  it "should find the airfield requested" do
    Airfield.should_receive(:find).with("1").and_return(@airfield)
    put_with_successful_update
  end

  it "should update the found airfield" do
    put_with_successful_update
    assigns(:airfield).should equal(@airfield)
  end

  it "should assign the found airfield for the view" do
    put_with_successful_update
    assigns(:airfield).should equal(@airfield)
  end

  it "should redirect to the airfield on successful update" do
    put_with_successful_update
    response.should redirect_to(airfield_url("1"))
  end

  it "should re-render 'edit' on failed update" do
    put_with_failed_update
    response.should render_template('edit')
  end
end

describe AirfieldsController, "handling DELETE /airfield/1" do

  before(:each) do
    controller.stub!(:authorized?).and_return(true)
  end

  before do
    @airfield = mock_model(Airfield, :destroy => true)
    Airfield.stub!(:find).and_return(@airfield)
  end
  
  def do_delete
    delete :destroy, :id => "1"
  end

  it "should find the airfield requested" do
    Airfield.should_receive(:find).with("1").and_return(@airfield)
    do_delete
  end
  
  it "should call destroy on the found airfield" do
    @airfield.should_receive(:destroy)
    do_delete
  end
  
  it "should redirect to the airfields list" do
    do_delete
    response.should redirect_to(airfields_url)
  end
end
