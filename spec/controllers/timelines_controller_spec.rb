require File.dirname(__FILE__) + '/../spec_helper'

describe TimelinesController do
  before(:each) do
  end

  it "should render a timeline for a plane" do
    Plane.stub!(:find).and_return(p = Plane.generate!)
    get :show, :plane_id => p.id
    response.should render_template("common/_timeline")
  end
  
end
