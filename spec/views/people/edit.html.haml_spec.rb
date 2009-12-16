require File.dirname(__FILE__) + '/../../spec_helper'

describe "/person/edit.html.haml" do
  include PeopleHelper
  
  before do
    @person = mock_model(Person)
    @person.stub!(:firstname).and_return("MyString")
    @person.stub!(:lastname).and_return("MyString")
    @person.stub!(:email).and_return("MyString")
    @person.stub!(:birthdate).and_return(Time.now)
    assigns[:person] = @person
  end

  it "should render edit form" do
    render "/people/edit.html.haml"
    
    response.should have_tag("form[action=#{person_path(@person)}][method=post]") do
      with_tag('input#person_firstname[name=?]', "person[firstname]")
      with_tag('input#person_lastname[name=?]', "person[lastname]")
      with_tag('input#person_email[name=?]', "person[email]")
    end
  end
end