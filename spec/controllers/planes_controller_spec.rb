require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PlanesController do

  def mock_plane(stubs={})
    @mock_plane ||= mock_model(Plane, stubs)
  end

  describe "GET index" do
    it "assigns all planes as @planes" do
      Plane.stub!(:find).with(:all).and_return([mock_plane])
      get :index
      assigns[:planes].should == [mock_plane]
    end
    
    it "should return json" do
      str = "str"
      mock_array = [mock_plane]
      mock_array.should_receive(:to_json).and_return(str)
      Plane.should_receive(:all).and_return(mock_array)
      get :index, :format => 'json'
      response.body.should == str
    end
  end

  describe "GET show" do
    it "assigns the requested plane as @plane" do
      Plane.stub!(:find).with("37").and_return(mock_plane)
      get :show, :id => "37"
      assigns[:plane].should equal(mock_plane)
    end
  end

  describe "GET new" do
    it "assigns a new plane as @plane" do
      Plane.stub!(:new).and_return(mock_plane)
      get :new
      assigns[:plane].should equal(mock_plane)
    end
  end

  describe "GET edit" do
    it "assigns the requested plane as @plane" do
      Plane.stub!(:find).with("37").and_return(mock_plane)
      get :edit, :id => "37"
      assigns[:plane].should equal(mock_plane)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created plane as @plane" do
        Plane.stub!(:new).with({'these' => 'params'}).and_return(mock_plane(:save => true))
        post :create, :plane => {:these => 'params'}
        assigns[:plane].should equal(mock_plane)
      end

      it "redirects to the created plane" do
        Plane.stub!(:new).and_return(mock_plane(:save => true))
        post :create, :plane => {}
        response.should redirect_to(plane_url(mock_plane))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved plane as @plane" do
        Plane.stub!(:new).with({'these' => 'params'}).and_return(mock_plane(:save => false))
        post :create, :plane => {:these => 'params'}
        assigns[:plane].should equal(mock_plane)
      end

      it "re-renders the 'new' template" do
        Plane.stub!(:new).and_return(mock_plane(:save => false))
        post :create, :plane => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested plane" do
        Plane.should_receive(:find).with("37").and_return(mock_plane)
        mock_plane.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :plane => {:these => 'params'}
      end

      it "assigns the requested plane as @plane" do
        Plane.stub!(:find).and_return(mock_plane(:update_attributes => true))
        put :update, :id => "1"
        assigns[:plane].should equal(mock_plane)
      end

      it "redirects to the plane" do
        Plane.stub!(:find).and_return(mock_plane(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(plane_url(mock_plane))
      end
    end

    describe "with invalid params" do
      it "updates the requested plane" do
        Plane.should_receive(:find).with("37").and_return(mock_plane)
        mock_plane.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :plane => {:these => 'params'}
      end

      it "assigns the plane as @plane" do
        Plane.stub!(:find).and_return(mock_plane(:update_attributes => false))
        put :update, :id => "1"
        assigns[:plane].should equal(mock_plane)
      end

      it "re-renders the 'edit' template" do
        Plane.stub!(:find).and_return(mock_plane(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested plane" do
      Plane.should_receive(:find).with("37").and_return(mock_plane)
      mock_plane.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the planes list" do
      Plane.stub!(:find).and_return(mock_plane(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(planes_url)
    end
  end

end
