require File.dirname(__FILE__) + '/../../spec_helper'

describe "/airfields/index.html.haml" do
  include AirfieldsHelper
  
  before do
    airfield_98 = mock_model(Airfield)
    airfield_98.should_receive(:registration).and_return("MyString")
    airfield_98.should_receive(:name).and_return("MyString")
    airfield_99 = mock_model(Airfield)
    airfield_99.should_receive(:registration).and_return("MyString")
    airfield_99.should_receive(:name).and_return("MyString")

    assigns[:airfields] = [airfield_98, airfield_99]
  end

  it "should render list of airfields" do
    render "/airfields/index.html.haml"
    response.should have_tag("tr>td", "MyString", 2)
    response.should have_tag("tr>td", "MyString", 2)
  end
end
