require File.dirname(__FILE__) + '/../../spec_helper'

describe "/person/edit.html.haml" do
  include PeopleHelper
  
  before do
    assigns[:person] = @person = Person.generate!
  end

  it "should render edit form" do
    render :template => "people/edit.html.haml"
    
#    response.should have_tag("form[action=#{person_path(@person)}][method=post]") do
#      with_tag('input#person_firstname[name=?]', "person[firstname]")
#      with_tag('input#person_lastname[name=?]', "person[lastname]")
#      with_tag('input#person_email[name=?]', "person[email]")
#    end
  end
end
