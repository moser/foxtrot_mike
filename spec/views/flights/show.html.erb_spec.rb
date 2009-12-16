require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/flights/show.html.erb" do
  include FlightsHelper
  before(:each) do
    assigns[:flight] = @flight = stub_model(Flight,
      :duration => 1
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/1/)
  end
end
