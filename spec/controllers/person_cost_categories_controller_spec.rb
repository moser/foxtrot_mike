require File.dirname(__FILE__) + '/../spec_helper'

describe PersonCostCategoriesController, "#route_for" do

  it "should map { :controller => 'person_cost_categories', :action => 'index' } to /person_cost_categories" do
    route_for(:controller => "person_cost_categories", :action => "index").should == "/person_cost_categories"
  end
  
  it "should map { :controller => 'person_cost_categories', :action => 'new' } to /person_cost_categories/new" do
    route_for(:controller => "person_cost_categories", :action => "new").should == "/person_cost_categories/new"
  end
  
  it "should map { :controller => 'person_cost_categories', :action => 'show', :id => 1 } to /person_cost_categories/1" do
    route_for(:controller => "person_cost_categories", :action => "show", :id => '1').should == "/person_cost_categories/1"
  end
  
  it "should map { :controller => 'person_cost_categories', :action => 'edit', :id => 1 } to /person_cost_categories/1/edit" do
    route_for(:controller => "person_cost_categories", :action => "edit", :id => '1').should == "/person_cost_categories/1/edit"
  end
  
  it "should map { :controller => 'person_cost_categories', :action => 'update', :id => 1} to /person_cost_categories/1" do
    route_for(:controller => "person_cost_categories", :action => "update", :id => '1').should == { :path => "/person_cost_categories/1", :method => :put }
  end
  
  it "should map { :controller => 'person_cost_categories', :action => 'destroy', :id => 1} to /person_cost_categories/1" do
    route_for(:controller => "person_cost_categories", :action => "destroy", :id => '1').should == { :path => "/person_cost_categories/1", :method => :delete }
  end
  
end

describe PersonCostCategoriesController, "handling GET /person_cost_categories" do

  before do
    @person_cost_category = mock_model(PersonCostCategory)
    PersonCostCategory.stub!(:find).and_return([@person_cost_category])
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
  
  it "should find all PersonCostCategories" do
    PersonCostCategory.should_receive(:find).with(:all).and_return([@person_cost_category])
    do_get
  end
  
  it "should assign the found PersonCostCategories for the view" do
    do_get
    assigns[:person_cost_categories].should == [@person_cost_category]
  end
  
  it "should return only objects changed after x"
end

describe PersonCostCategoriesController, "handling GET /person_cost_categories.json" do

  before do
    @person_cost_category = mock_model(PersonCostCategory, :to_json => "JSON")
    PersonCostCategory.stub!(:find).and_return(@person_cost_category)
  end
  
  def do_get
    @request.env["HTTP_ACCEPT"] = "application/json"
    get :index
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end

  it "should find all PersonCostCategories" do
    PersonCostCategory.should_receive(:find).with(:all).and_return([@person_cost_category])
    do_get
  end
  
  it "should render the found PersonCostCategory as json" do
    @person_cost_category.should_receive(:to_json).and_return("JSON")
    do_get
    response.body.should == "JSON"
  end
  
  it "should return only objects changed after x"
end

describe PersonCostCategoriesController, "handling GET /person_cost_categories/1" do

  before do
    @person_cost_category = mock_model(PersonCostCategory)
    PersonCostCategory.stub!(:find).and_return(@person_cost_category)
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
  
  it "should find the person_cost_category requested" do
    PersonCostCategory.should_receive(:find).with("1").and_return(@person_cost_category)
    do_get
  end
  
  it "should assign the found person_cost_category for the view" do
    do_get
    assigns[:person_cost_category].should equal(@person_cost_category)
  end
end

describe PersonCostCategoriesController, "handling GET /person_cost_categories/1.json" do

  before do
    @person_cost_category = mock_model(PersonCostCategory, :to_json => "JSON")
    PersonCostCategory.stub!(:find).and_return(@person_cost_category)
  end
  
  def do_get
    @request.env["HTTP_ACCEPT"] = "application/json"
    get :show, :id => "1"
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should find the person_cost_category requested" do
    PersonCostCategory.should_receive(:find).with("1").and_return(@person_cost_category)
    do_get
  end
  
  it "should render the found person_cost_category as json" do
    @person_cost_category.should_receive(:to_json).and_return("JSON")
    do_get
    response.body.should == "JSON"
  end
end

describe PersonCostCategoriesController, "handling GET /person_cost_categories/new" do

  before do
    @person_cost_category = mock_model(PersonCostCategory)
    PersonCostCategory.stub!(:new).and_return(@person_cost_category)
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
  
  it "should create an new person_cost_category" do
    PersonCostCategory.should_receive(:new).and_return(@person_cost_category)
    do_get
  end
  
  it "should not save the new person_cost_category" do
    @person_cost_category.should_not_receive(:save)
    do_get
  end
  
  it "should assign the new person_cost_category for the view" do
    do_get
    assigns[:person_cost_category].should equal(@person_cost_category)
  end
end

describe PersonCostCategoriesController, "handling GET /person_cost_categories/1/edit" do

  before do
    @person_cost_category = mock_model(PersonCostCategory)
    PersonCostCategory.stub!(:find).and_return(@person_cost_category)
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
  
  it "should find the person_cost_category requested" do
    PersonCostCategory.should_receive(:find).and_return(@person_cost_category)
    do_get
  end
  
  it "should assign the found person_cost_category for the view" do
    do_get
    assigns[:person_cost_category].should equal(@person_cost_category)
  end
end

describe PersonCostCategoriesController, "handling POST /person_cost_categories" do

  before do
    @person_cost_category = mock_model(PersonCostCategory, :to_param => "1")
    PersonCostCategory.stub!(:new).and_return(@person_cost_category)
  end
  
  def post_with_successful_save
    @person_cost_category.should_receive(:save).and_return(true)
    post :create, :person_cost_category => {}
  end
  
  def post_with_failed_save
    @person_cost_category.should_receive(:save).and_return(false)
    post :create, :person_cost_category => {}
  end
  
  it "should create a new person_cost_category" do
    PersonCostCategory.should_receive(:new).with({}).and_return(@person_cost_category)
    post_with_successful_save
  end

  it "should redirect to the new person_cost_category on successful save" do
    post_with_successful_save
    response.should redirect_to(person_cost_category_url("1"))
  end

  it "should re-render 'new' on failed save" do
    post_with_failed_save
    response.should render_template('new')
  end
end

describe PersonCostCategoriesController, "handling PUT /person_cost_categories/1" do

  before do
    @person_cost_category = mock_model(PersonCostCategory, :to_param => "1")
    PersonCostCategory.stub!(:find).and_return(@person_cost_category)
  end
  
  def put_with_successful_update
    @person_cost_category.should_receive(:update_attributes).and_return(true)
    put :update, :id => "1"
  end
  
  def put_with_failed_update
    @person_cost_category.should_receive(:update_attributes).and_return(false)
    put :update, :id => "1"
  end
  
  it "should find the person_cost_category requested" do
    PersonCostCategory.should_receive(:find).with("1").and_return(@person_cost_category)
    put_with_successful_update
  end

  it "should update the found person_cost_category" do
    put_with_successful_update
    assigns(:person_cost_category).should equal(@person_cost_category)
  end

  it "should assign the found person_cost_category for the view" do
    put_with_successful_update
    assigns(:person_cost_category).should equal(@person_cost_category)
  end

  it "should redirect to the person_cost_category on successful update" do
    put_with_successful_update
    response.should redirect_to(person_cost_category_url("1"))
  end

  it "should re-render 'edit' on failed update" do
    put_with_failed_update
    response.should render_template('edit')
  end
end

describe PersonCostCategoriesController, "handling DELETE /PersonCostCategory/1" do

  before do
    @person_cost_category = mock_model(PersonCostCategory, :destroy => true)
    PersonCostCategory.stub!(:find).and_return(@person_cost_category)
  end
  
  def do_delete
    delete :destroy, :id => "1"
  end

  it "should find the person_cost_category requested" do
    PersonCostCategory.should_receive(:find).with("1").and_return(@person_cost_category)
    do_delete
  end
  
  it "should call destroy on the found person_cost_category" do
    @person_cost_category.should_receive(:destroy)
    do_delete
  end
  
  it "should redirect to the PersonCostCategories list" do
    do_delete
    response.should redirect_to(person_cost_categories_url)
  end
end
