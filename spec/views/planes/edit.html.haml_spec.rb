require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/planes/edit.html.haml" do
  include PlanesHelper

  before(:each) do
    assigns[:plane] = @plane = Plane.generate!
  end

  it "renders the edit plane form" do
    render

#    response.should have_tag("form[action=#{plane_path(@plane)}][method=post]") do
#    end
  end
end
