require File.dirname(__FILE__) + '/../../spec_helper'

describe "/airfields/index.html.haml" do
  include AirfieldsHelper
  
  before do
    assigns[:airfields] = @airfields = [Airfield.generate!, Airfield.generate!]
  end

  it "should render list of airfields" do
    render :template => "airfields/index.html.haml"
#    response.should have_tag("tr>td", "MyString", 2)
#    response.should have_tag("tr>td", "MyString", 2)
  end
end
