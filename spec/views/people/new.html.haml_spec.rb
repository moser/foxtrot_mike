require File.dirname(__FILE__) + '/../../spec_helper'

describe "/people/new.html.haml" do
  include PeopleHelper
  
  before do
    assigns[:person] = @person = Person.spawn
  end

  it "should render new form" do
    render :template => "people/new.html.haml"
    
#    response.should have_tag("form[action=?][method=post]", people_path) do
#      with_tag("input#person_firstname[name=?]", "person[firstname]")
#      with_tag("input#person_lastname[name=?]", "person[lastname]")
#      with_tag("input#person_email[name=?]", "person[email]")
#    end
  end
end
