require File.dirname(__FILE__) + '/../spec_helper'

describe PlaneCostCategoriesController, "#route_for" do

  it "should map { :controller => 'plane_cost_categories', :action => 'index' } to /plane_cost_categories" do
    route_for(:controller => "plane_cost_categories", :action => "index").should == "/plane_cost_categories"
  end
  
  it "should map { :controller => 'plane_cost_categories', :action => 'new' } to /plane_cost_categories/new" do
    route_for(:controller => "plane_cost_categories", :action => "new").should == "/plane_cost_categories/new"
  end
  
  it "should map { :controller => 'plane_cost_categories', :action => 'show', :id => 1 } to /plane_cost_categories/1" do
    route_for(:controller => "plane_cost_categories", :action => "show", :id => '1').should == "/plane_cost_categories/1"
  end
  
  it "should map { :controller => 'plane_cost_categories', :action => 'edit', :id => 1 } to /plane_cost_categories/1/edit" do
    route_for(:controller => "plane_cost_categories", :action => "edit", :id => '1').should == "/plane_cost_categories/1/edit"
  end
  
  it "should map { :controller => 'plane_cost_categories', :action => 'update', :id => 1} to /plane_cost_categories/1" do
    route_for(:controller => "plane_cost_categories", :action => "update", :id => '1').should == { :path => "/plane_cost_categories/1", :method => :put }
  end
  
  it "should map { :controller => 'plane_cost_categories', :action => 'destroy', :id => 1} to /plane_cost_categories/1" do
    route_for(:controller => "plane_cost_categories", :action => "destroy", :id => '1').should == { :path => "/plane_cost_categories/1", :method => :delete }
  end
  
end

describe PlaneCostCategoriesController, "handling GET /plane_cost_categories" do

  before do
    @plane_cost_category = mock_model(PlaneCostCategory)
    PlaneCostCategory.stub!(:find).and_return([@plane_cost_category])
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
  
  it "should find all PlaneCostCategories" do
    PlaneCostCategory.should_receive(:find).with(:all).and_return([@plane_cost_category])
    do_get
  end
  
  it "should assign the found PlaneCostCategories for the view" do
    do_get
    assigns[:plane_cost_categories].should == [@plane_cost_category]
  end
  
  it "should return only objects changed after x"
end

describe PlaneCostCategoriesController, "handling GET /plane_cost_categories.json" do

  before do
    @plane_cost_category = mock_model(PlaneCostCategory, :to_json => "JSON")
    PlaneCostCategory.stub!(:find).and_return(@plane_cost_category)
  end
  
  def do_get
    @request.env["HTTP_ACCEPT"] = "application/json"
    get :index
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end

  it "should find all PlaneCostCategories" do
    PlaneCostCategory.should_receive(:find).with(:all).and_return([@plane_cost_category])
    do_get
  end
  
  it "should render the found PlaneCostCategory as json" do
    @plane_cost_category.should_receive(:to_json).and_return("JSON")
    do_get
    response.body.should == "JSON"
  end
  
  it "should return only objects changed after x"
end

describe PlaneCostCategoriesController, "handling GET /plane_cost_categories/1" do

  before do
    @plane_cost_category = mock_model(PlaneCostCategory)
    PlaneCostCategory.stub!(:find).and_return(@plane_cost_category)
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
  
  it "should find the plane_cost_category requested" do
    PlaneCostCategory.should_receive(:find).with("1").and_return(@plane_cost_category)
    do_get
  end
  
  it "should assign the found plane_cost_category for the view" do
    do_get
    assigns[:plane_cost_category].should equal(@plane_cost_category)
  end
end

describe PlaneCostCategoriesController, "handling GET /plane_cost_categories/1.json" do

  before do
    @plane_cost_category = mock_model(PlaneCostCategory, :to_json => "JSON")
    PlaneCostCategory.stub!(:find).and_return(@plane_cost_category)
  end
  
  def do_get
    @request.env["HTTP_ACCEPT"] = "application/json"
    get :show, :id => "1"
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should find the plane_cost_category requested" do
    PlaneCostCategory.should_receive(:find).with("1").and_return(@plane_cost_category)
    do_get
  end
  
  it "should render the found plane_cost_category as json" do
    @plane_cost_category.should_receive(:to_json).and_return("JSON")
    do_get
    response.body.should == "JSON"
  end
end

describe PlaneCostCategoriesController, "handling GET /plane_cost_categories/new" do

  before do
    @plane_cost_category = mock_model(PlaneCostCategory)
    PlaneCostCategory.stub!(:new).and_return(@plane_cost_category)
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
  
  it "should create an new plane_cost_category" do
    PlaneCostCategory.should_receive(:new).and_return(@plane_cost_category)
    do_get
  end
  
  it "should not save the new plane_cost_category" do
    @plane_cost_category.should_not_receive(:save)
    do_get
  end
  
  it "should assign the new plane_cost_category for the view" do
    do_get
    assigns[:plane_cost_category].should equal(@plane_cost_category)
  end
end

describe PlaneCostCategoriesController, "handling GET /plane_cost_categories/1/edit" do

  before do
    @plane_cost_category = mock_model(PlaneCostCategory)
    PlaneCostCategory.stub!(:find).and_return(@plane_cost_category)
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
  
  it "should find the plane_cost_category requested" do
    PlaneCostCategory.should_receive(:find).and_return(@plane_cost_category)
    do_get
  end
  
  it "should assign the found plane_cost_category for the view" do
    do_get
    assigns[:plane_cost_category].should equal(@plane_cost_category)
  end
end

describe PlaneCostCategoriesController, "handling POST /plane_cost_categories" do

  before do
    @plane_cost_category = mock_model(PlaneCostCategory, :to_param => "1")
    PlaneCostCategory.stub!(:new).and_return(@plane_cost_category)
  end
  
  def post_with_successful_save
    @plane_cost_category.should_receive(:save).and_return(true)
    post :create, :plane_cost_category => {}
  end
  
  def post_with_failed_save
    @plane_cost_category.should_receive(:save).and_return(false)
    post :create, :plane_cost_category => {}
  end
  
  it "should create a new plane_cost_category" do
    PlaneCostCategory.should_receive(:new).with({}).and_return(@plane_cost_category)
    post_with_successful_save
  end

  it "should redirect to the new plane_cost_category on successful save" do
    post_with_successful_save
    response.should redirect_to(plane_cost_category_url("1"))
  end

  it "should re-render 'new' on failed save" do
    post_with_failed_save
    response.should render_template('new')
  end
end

describe PlaneCostCategoriesController, "handling PUT /plane_cost_categories/1" do

  before do
    @plane_cost_category = mock_model(PlaneCostCategory, :to_param => "1")
    PlaneCostCategory.stub!(:find).and_return(@plane_cost_category)
  end
  
  def put_with_successful_update
    @plane_cost_category.should_receive(:update_attributes).and_return(true)
    put :update, :id => "1"
  end
  
  def put_with_failed_update
    @plane_cost_category.should_receive(:update_attributes).and_return(false)
    put :update, :id => "1"
  end
  
  it "should find the plane_cost_category requested" do
    PlaneCostCategory.should_receive(:find).with("1").and_return(@plane_cost_category)
    put_with_successful_update
  end

  it "should update the found plane_cost_category" do
    put_with_successful_update
    assigns(:plane_cost_category).should equal(@plane_cost_category)
  end

  it "should assign the found plane_cost_category for the view" do
    put_with_successful_update
    assigns(:plane_cost_category).should equal(@plane_cost_category)
  end

  it "should redirect to the plane_cost_category on successful update" do
    put_with_successful_update
    response.should redirect_to(plane_cost_category_url("1"))
  end

  it "should re-render 'edit' on failed update" do
    put_with_failed_update
    response.should render_template('edit')
  end
end

describe PlaneCostCategoriesController, "handling DELETE /PlaneCostCategory/1" do

  before do
    @plane_cost_category = mock_model(PlaneCostCategory, :destroy => true)
    PlaneCostCategory.stub!(:find).and_return(@plane_cost_category)
  end
  
  def do_delete
    delete :destroy, :id => "1"
  end

  it "should find the plane_cost_category requested" do
    PlaneCostCategory.should_receive(:find).with("1").and_return(@plane_cost_category)
    do_delete
  end
  
  it "should call destroy on the found plane_cost_category" do
    @plane_cost_category.should_receive(:destroy)
    do_delete
  end
  
  it "should redirect to the PlaneCostCategories list" do
    do_delete
    response.should redirect_to(plane_cost_categories_url)
  end
end
