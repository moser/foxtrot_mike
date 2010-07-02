require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/planes/index.html.haml" do
  include PlanesHelper

  before(:each) do
    assigns[:planes] = @planes = [
      Plane.generate!,
      Plane.generate!
    ]
  end

  it "renders a list of planes" do
    render
  end
end
