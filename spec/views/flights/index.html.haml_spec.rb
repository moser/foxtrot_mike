require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/flights/index.html.haml" do
  include FlightsHelper

  before(:each) do
    assigns[:flights] = [
      stub_model(Flight,
        :duration => 1,
        :crew => Factory.stub(:crew)
      ),
      stub_model(Flight,
        :duration => 1,
        :crew => Factory.stub(:crew)
      )
    ]
  end

  it "renders a list of flights" do
    render
    response.should have_tag("tr>td", 1.to_s, 2)
  end
end
