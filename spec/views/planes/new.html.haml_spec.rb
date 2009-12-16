require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/planes/new.html.haml" do
  include PlanesHelper

  before(:each) do
    assigns[:plane] = stub_model(Plane,
      :new_record? => true
    )
  end

  it "renders new plane form" do
    render

    response.should have_tag("form[action=?][method=post]", planes_path) do
    end
  end
end
