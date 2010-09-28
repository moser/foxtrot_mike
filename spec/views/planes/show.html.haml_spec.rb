require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/planes/show.html.haml" do
  include PlanesHelper
  before(:each) do
    assigns[:plane] = @plane = Plane.generate!
  end

  it "should render" do
    render
  end
end
