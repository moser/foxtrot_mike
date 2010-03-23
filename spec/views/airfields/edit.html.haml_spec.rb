require File.dirname(__FILE__) + '/../../spec_helper'

describe "/airfield/edit.html.haml" do
  include AirfieldsHelper
  
  before do
    @airfield = mock_model(Airfield)
    @airfield.stub!(:registration).and_return("MyString")
    @airfield.stub!(:name).and_return("MyString")
    @airfield.errors.stub!(:[]).and_return(nil)
    assigns[:airfield] = @airfield
  end

  it "should render edit form" do
    render "/airfields/edit.html.haml"
    
    response.should have_tag("form[action=#{airfield_path(@airfield)}][method=post]") do
      with_tag('input#airfield_registration[name=?]', "airfield[registration]")
      with_tag('input#airfield_name[name=?]', "airfield[name]")
    end
  end
end
