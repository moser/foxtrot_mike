require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/flights/show.html.haml" do
  helper :application, :flights
  
  before(:each) do
    assigns[:flight] = @flight = Flight.generate!
  end

  it "render without errors" do
    render
  end
end
