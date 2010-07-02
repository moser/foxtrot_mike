require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/flights/index.html.haml" do
  helper :application, :flights

  before(:each) do
    assigns[:flights] = @flights = [
      Flight.generate!,
      Flight.generate!
    ]
  end

  it "renders a list of flights" do
    render
#    response.should have_tag("tr>td", "0:01", 2)
  end
end
