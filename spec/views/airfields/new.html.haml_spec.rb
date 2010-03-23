require File.dirname(__FILE__) + '/../../spec_helper'

describe "/airfields/new.html.haml" do
  include AirfieldsHelper
  
  before do
    @airfield = mock_model(Airfield)
    @airfield.stub!(:new_record?).and_return(true)
    @airfield.stub!(:registration).and_return("MyString")
    @airfield.stub!(:name).and_return("MyString")
    @airfield.errors.stub!(:[]).and_return(nil)
    assigns[:airfield] = @airfield
  end

  it "should render new form" do
    render "/airfields/new.html.haml"
    
    response.should have_tag("form[action=?][method=post]", airfields_path) do
      with_tag("input#airfield_registration[name=?]", "airfield[registration]")
      with_tag("input#airfield_name[name=?]", "airfield[name]")
    end
  end
end
