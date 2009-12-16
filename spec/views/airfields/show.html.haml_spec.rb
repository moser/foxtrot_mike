require File.dirname(__FILE__) + '/../../spec_helper'

describe "/airfields/show.html.haml" do
  include AirfieldsHelper
  
  before do
    @airfield = mock_model(Airfield)
    @airfield.stub!(:registration).and_return("MyString")
    @airfield.stub!(:name).and_return("MyString")

    assigns[:airfield] = @airfield
  end

  it "should render attributes in <p>" do
    render "/airfields/show.html.haml"
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
  end
end

