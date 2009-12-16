require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/planes/index.html.haml" do
  include PlanesHelper

  before(:each) do
    assigns[:planes] = [
      stub_model(Plane),
      stub_model(Plane)
    ]
  end

  it "renders a list of planes" do
    render
  end
end
