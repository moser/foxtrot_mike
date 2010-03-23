require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/flights/new.html.haml" do
  include FlightsHelper

  before(:each) do
    assigns[:flight] = stub_model(Flight,
      :new_record? => true,
      :duration => 1
    )
  end

  it "renders new flight form" do
    render

    response.should have_tag("form[action=?][method=post]", flights_path) do
      with_tag("input#flight_plane[name=?]", "flight[plane]")
    end
  end
end
