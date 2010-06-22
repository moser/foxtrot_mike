require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FlightsController do
  #TODO
  fixtures        :accounts
  
  before(:each) do
    login_as accounts(:quentin)
  end

  def mock_flight(stubs={})
    @mock_flight ||= mock_model(Flight, stubs)
  end

  describe "GET index" do
    it "assigns all flights as @flights" do
      Flight.stub!(:find).with(:all).and_return([mock_flight])
      get :index
      assigns[:flights].should == [mock_flight]
    end
  end

  describe "GET show" do
    it "assigns the requested flight as @flight" do
      Flight.stub!(:find).with("37").and_return(mock_flight)
      get :show, :id => "37"
      assigns[:flight].should equal(mock_flight)
    end
  end

  describe "GET new" do
    it "assigns a new flight as @flight" do
      Flight.stub!(:new).and_return(mock_flight)
      get :new
      assigns[:flight].should equal(mock_flight)
    end
  end

  describe "GET edit" do
    it "assigns the requested flight as @flight" do
      Flight.stub!(:find).with("37").and_return(mock_flight)
      get :edit, :id => "37"
      assigns[:flight].should equal(mock_flight)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created flight as @flight" do
        Flight.stub!(:new).with({'these' => 'params'}).and_return(mock_flight(:save => true))
        post :create, :flight => {:these => 'params'}
        assigns[:flight].should equal(mock_flight)
      end

     it "redirects to the edit" do
        Flight.stub!(:new).and_return(mock_flight(:save => true))
        post :create, :flight => {}
        response.should redirect_to(edit_flight_url(mock_flight))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved flight as @flight" do
        Flight.stub!(:new).with({'these' => 'params'}).and_return(mock_flight(:save => false))
        post :create, :flight => {:these => 'params'}
        assigns[:flight].should equal(mock_flight)
      end

      it "re-renders the 'new' template" do
        Flight.stub!(:new).and_return(mock_flight(:save => false))
        post :create, :flight => {}
        response.should render_template('new')
      end
    end
    
    describe "with JSON params" do
      it "should create a flight with a launch and 2 crew members"
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested flight" do
        Flight.should_receive(:find).with("37").and_return(mock_flight)
        mock_flight.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :flight => {:these => 'params'}
      end

      it "assigns the requested flight as @flight" do
        Flight.stub!(:find).and_return(mock_flight(:update_attributes => true))
        put :update, :id => "1"
        assigns[:flight].should equal(mock_flight)
      end

      it "redirects to the flight" do
        Flight.stub!(:find).and_return(mock_flight(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(flight_url(mock_flight))
      end
    end

    describe "with invalid params" do
      it "updates the requested flight" do
        Flight.should_receive(:find).with("37").and_return(mock_flight)
        mock_flight.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :flight => {:these => 'params'}
      end

      it "assigns the flight as @flight" do
        Flight.stub!(:find).and_return(mock_flight(:update_attributes => false))
        put :update, :id => "1"
        assigns[:flight].should equal(mock_flight)
      end

      it "re-renders the 'edit' template" do
        Flight.stub!(:find).and_return(mock_flight(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested flight" do
      Flight.should_receive(:find).with("37").and_return(mock_flight)
      mock_flight.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the flights list" do
      Flight.stub!(:find).and_return(mock_flight(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(flights_url)
    end
  end

end
