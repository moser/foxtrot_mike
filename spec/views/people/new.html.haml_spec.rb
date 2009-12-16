require File.dirname(__FILE__) + '/../../spec_helper'

describe "/people/new.html.haml" do
  include PeopleHelper
  
  before do
    @person = mock_model(Person)
    @person.stub!(:new_record?).and_return(true)
    @person.stub!(:firstname).and_return("MyString")
    @person.stub!(:lastname).and_return("MyString")
    @person.stub!(:email).and_return("MyString")
    @person.stub!(:birthdate).and_return(Time.now)
    assigns[:person] = @person
  end

  it "should render new form" do
    render "/people/new.html.haml"
    
    response.should have_tag("form[action=?][method=post]", people_path) do
      with_tag("input#person_firstname[name=?]", "person[firstname]")
      with_tag("input#person_lastname[name=?]", "person[lastname]")
      with_tag("input#person_email[name=?]", "person[email]")
    end
  end
end
