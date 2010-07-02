require File.dirname(__FILE__) + '/../../spec_helper'

describe "/airfield/edit.html.haml" do
  include AirfieldsHelper
  
  before do
    assigns[:airfield] = @airfield = Airfield.generate!
  end

  it "should render edit form" do
    render :template => "airfields/edit.html.haml"
    
#    response.should have_tag("form[action=#{airfield_path(@airfield)}][method=post]") do
#      with_tag('input#airfield_registration[name=?]', "airfield[registration]")
#      with_tag('input#airfield_name[name=?]', "airfield[name]")
#    end
  end
end
