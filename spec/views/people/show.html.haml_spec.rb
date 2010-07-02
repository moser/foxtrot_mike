require File.dirname(__FILE__) + '/../../spec_helper'

describe "/people/show.html.haml" do
  include PeopleHelper
  
  before do
    @person = mock_model(Person)
    @person.stub!(:firstname).and_return("MyString")
    @person.stub!(:lastname).and_return("MyString")
    @person.stub!(:email).and_return("MyString")
    @person.stub!(:birthdate).and_return(Time.now)

    assigns[:person] = @person
  end

  it "should render attributes in <p>" do
    render :template => "people/show.html.haml"
#    response.should have_text(/MyString/)
#    response.should have_text(/MyString/)
#    response.should have_text(/MyString/)
  end
end

