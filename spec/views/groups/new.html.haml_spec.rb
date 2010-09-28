require File.dirname(__FILE__) + '/../../spec_helper'

describe "/airfields/new.html.haml" do
  include AirfieldsHelper
  
  before do
    assigns[:airfield] = @airfield = Airfield.spawn
  end

  it "should render new form" do
    render :template => "airfields/new.html.haml"
    
#    response.should have_tag("form[action=?][method=post]", airfields_path) do
#      with_tag("input#airfield_registration[name=?]", "airfield[registration]")
#      with_tag("input#airfield_name[name=?]", "airfield[name]")
#    end
  end
end
