require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/planes/show.html.haml" do
  include PlanesHelper
  before(:each) do
    assigns[:plane] = @plane = Plane.generate!
  end

  it "renders attributes in <p>" do
    render
  end
end
