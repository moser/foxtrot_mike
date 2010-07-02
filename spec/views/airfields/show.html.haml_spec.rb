require File.dirname(__FILE__) + '/../../spec_helper'

describe "/airfields/show.html.haml" do
  include AirfieldsHelper
  
  before do
    assigns[:airfield] = @airfield = Airfield.generate!
  end

  it "should render attributes in <p>" do
    render :template => "airfields/show.html.haml"
#    response.should have_text(/MyString/)
#    response.should have_text(/MyString/)
  end
end

